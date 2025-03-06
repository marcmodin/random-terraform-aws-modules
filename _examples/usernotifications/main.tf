# import {
#   to = awscc_notifications_notification_hub.default
#   id = "eu-north-1"
# }

resource "awscc_notifications_notification_hub" "default" {
  region = "eu-north-1"
}

# import {
#   to = awscc_notificationscontacts_email_contact.default
#   id = "arn:aws:notifications-contacts::971422678851:emailcontact/a01jnnrsyka8bqgrq6cv297315a"
# }

resource "awscc_notificationscontacts_email_contact" "default" {
  name = "marc"
  email_address = "marc@playgroundtech.io"
}


# import {
#   to = awscc_notifications_notification_configuration.default
#   id = "arn:aws:notifications::971422678851:configuration/a01jnnbj0yah3zfp54zy1153xhc"
# }

resource "awscc_notifications_notification_configuration" "default" {
  name = "CloudWatch-quick-setup"
  description = "CloudWatch notifications created with quick setup"
}

# import {
#   to = awscc_notifications_event_rule.default
#   id = "arn:aws:notifications::971422678851:configuration/a01jnnbj0yah3zfp54zy1153xhc/rule/a01jnnbj158smtstt77b2cyqgxj"
#   # get the rule arn : aws notifications list-event-rules --notification-configuration-arn "<arn>" --region "us-east-1"
# }

resource "awscc_notifications_event_rule" "default" {
  notification_configuration_arn = awscc_notifications_notification_configuration.default.arn
  regions = ["eu-north-1"]
  source = "aws.cloudwatch"
  event_type = "CloudWatch Alarm State Change"
    event_pattern                  = trimspace(jsonencode(
        {
          detail = {
            state = {
              value = ["ALARM"]
            }
          }
          # resources = ["arn:aws:cloudwatch:eu-north-1:971422678851:alarm:ec2-alarm",]
        }
    ))
}


resource "awscc_notifications_channel_association" "default" {
  notification_configuration_arn = awscc_notifications_notification_configuration.default.arn
  arn = awscc_notificationscontacts_email_contact.default.arn
}