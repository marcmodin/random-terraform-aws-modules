import os
import logging
import base64
import json
import datetime

# configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

if os.environ['DEBUG'].lower() == 'true':
    logger.setLevel(logging.DEBUG)


# get ocsf config for mapping
mapping_config = open('OCSFmapping.json')
custom_source_mapping = json.load(mapping_config)


def timestamp_transform(timestamp, format):
    """ function to return eventday format from user-specified timestamp found in logs """
    if format == 'epoch':
        dt_event = datetime.fromtimestamp(int(timestamp))
        eventday = str(dt_event.year) + \
            f'{dt_event.month:02d}'+f'{dt_event.day:02d}'
        return eventday
    else:
        dt_event = datetime.strptime(timestamp, format)
        eventday = str(dt_event.year) + \
            f'{dt_event.month:02d}'+f'{dt_event.day:02d}'
        return eventday


def get_dot_locator_value(dot_locator, event):
    """ function to return value from '$.' reference in config line """
    if dot_locator.startswith('$.'):
        json_path = dot_locator.split('.')
        if json_path[1] == 'UserDefined':
            return event[json_path[2]]
        json_path.pop(0)
        result = {}
        result = event
        for k in json_path:
            if result.get(k) is not None:
                result = result.get(k)
            else:  # if we get None then reference doesnt exist and we need to break out
                result = None
                break
        return str(result)
    else:
        logger.info("Unable to process matched field -"+dot_locator)


def perform_transform(event_mapping, event):
    """ function to map original log record to mapping defined in config file """
    new_record = {}
    for key in event_mapping.keys():
        # if we have a dict as the value we need to keep traversing until we reach a leaf
        if type(event_mapping[key]) is dict:
            if 'enum' in event_mapping[key]:
                if isinstance(event_mapping[key]['enum']['evaluate'], str) and (event_mapping[key]['enum']['evaluate'].startswith('$.')):
                    value = get_dot_locator_value(
                        event_mapping[key]['enum']['evaluate'], event)
                    if value in event_mapping[key]['enum']['values']:
                        new_record[key] = event_mapping[key]['enum']['values'][value]
                    else:
                        new_record[key] = event_mapping[key]['enum']['other']
            else:
                new_record[key] = perform_transform(event_mapping[key], event)
        else:  # we have reached a leaf node
            # get the field if dot locator
            if isinstance(event_mapping[key], str) and (event_mapping[key].startswith('$.')):
                locator_value = get_dot_locator_value(
                    event_mapping[key], event)
                if locator_value is not None:
                    new_record[key] = locator_value
            else:
                # otherwise just map it
                new_record[key] = event_mapping[key]

    return new_record


def process_kinesis_event(record):

    logger.info('Processing Kinesis event')

    mapped_events = []
    unmapped_events = []
    payload_json = {}

    payload = base64.b64decode(record['kinesis']['data']).decode('utf-8')
    logger.debug("Raw log: "+str(payload))
    payload_json = json.loads(payload)

    matched_value = get_dot_locator_value(
        custom_source_mapping['custom_source_events']['matched_field'], payload_json)
    logger.debug("Matched value: "+str(matched_value))

    # if its a windows-sysmon event then we need to tweak it to get it into json format
    if custom_source_mapping['custom_source_events']['source_name'] == 'windows-sysmon':
        data = {}
        for line in payload_json['Description'].split('\r\n'):
            parts = line.split(': ', 1)  # Splitting by ': '
            key = parts[0]
            # If value is present, assign it to the key, otherwise assign an empty string
            value = parts[1] if len(parts) > 1 else ""
            data[key] = value
        payload_json['Description'] = data

    logger.debug(payload_json)

    # save timestamp information
    partition = {}
    partition['timestamp'] = get_dot_locator_value(
        custom_source_mapping['custom_source_events']['timestamp']['field'], payload_json)
    partition['format'] = custom_source_mapping['custom_source_events']['timestamp']['format']
    partition['eventday'] = timestamp_transform(
        partition['timestamp'], partition['format'])

    logger.debug("Eventday: "+str(partition['eventday']))

    if matched_value in custom_source_mapping['custom_source_events']['ocsf_mapping']:
        logger.debug("Found event mapping: "+str(
            custom_source_mapping['custom_source_events']['ocsf_mapping'][matched_value]))
        new_map = perform_transform(
            custom_source_mapping['custom_source_events']['ocsf_mapping'][matched_value]['schema_mapping'], payload_json)
        new_schema = {}
        new_schema['target_schema'] = custom_source_mapping['custom_source_events']['ocsf_mapping'][matched_value]['schema']
        new_schema['target_mapping'] = new_map
        new_schema['eventday'] = partition['eventday']

        logger.debug("Transformed OCSF record: "+str(new_schema))

        mapped_events.append(new_schema)

    else:
        logger.info("Found unmapped event")
        unmapped_events.append(payload_json)

    return mapped_events, unmapped_events


def lambda_handler(event, context):

    logger.info("Received event: "+json.dumps(event, indent=2))

    # mapped_events = []
    # unmapped_events = []

    # for record in event['records']:
    #     logger.info('Record eventSource: '+record['eventSource'])
    #     if record['eventSource'] == 'aws:kinesis':
    #         logger.info('Record eventID: '+record['eventID'])
    #         mapped, unmapped = process_kinesis_event(record)
    #         logger.debug(mapped)
    #         logger.debug(unmapped)
    #         mapped_events.extend(mapped)
    #         unmapped_events.extend(unmapped)
    #     else:
    #         logger.info("Event source not supported.")

    # At the end return processed records
    return event['records']
