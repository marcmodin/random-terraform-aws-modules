locals {

  extended_data_source = "s3://${module.flow_logs.bucket_id}/vpc-logs-parquet-extended/AWSLogs/"

  parameters = {
    "classification"              = "parquet"
    "compressionType"             = "none"
    "partition_filtering.enabled" = "true"
    "typeOfData"                  = "file"
  }

  partition_index = {
    index_name = "default"
    keys       = ["month", "day", "hour"]
  }

  partition_keys = {
    "1" = {
      name = "aws_account_id"
      type = "string"
    }
    "2" = {
      name = "aws_service"
      type = "string"
    }
    "3" = {
      name = "aws_region"
      type = "string"
    }
    "4" = {
      name = "year"
      type = "string"
    },
    "5" = {
      name = "month"
      type = "string"
    },
    "6" = {
      name = "day"
      type = "string"
    },
    "7" = {
      name = "hour"
      type = "string"
    }
  }

  # Original log_format string
  log_format = "$${account-id} $${vpc-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${tcp-flags} $${log-status} $${action} $${interface-id} $${subnet-id} $${instance-id} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"

  # Split the log_format into individual fields by space
  raw_fields = split(" ", local.log_format)

  # Extract field names by removing the surrounding '$${' and '}' from each field
  extracted_fields = [for field in local.raw_fields : replace(replace(field, "$${", ""), "}", "")]

  # Convert kebab-case field names to snake_case for Terraform compatibility
  snake_case_fields = [for field in local.extracted_fields : replace(field, "-", "_")]

  # Define a mapping of field names to their respective data types
  # Adjust the types as necessary based on your specific requirements
  field_types = {
    "account_id"          = "string"
    "vpc_id"              = "string"
    "srcaddr"             = "string"
    "dstaddr"             = "string"
    "srcport"             = "int"
    "dstport"             = "int"
    "protocol"            = "int"
    "packets"             = "bigint"
    "bytes"               = "bigint"
    "start"               = "bigint"
    "end"                 = "bigint"
    "log_status"          = "string"
    "action"              = "string"
    "interface_id"        = "string"
    "subnet_id"           = "string"
    "instance_id"         = "string"
    "tcp_flags"           = "int"
    "type"                = "string"
    "pkt_srcaddr"         = "string"
    "pkt_dstaddr"         = "string"
    "region"              = "string"
    "az_id"               = "string"
    "sublocation_type"    = "string"
    "sublocation_id"      = "string"
    "pkt_src_aws_service" = "string"
    "pkt_dst_aws_service" = "string"
    "flow_direction"      = "string"
    "traffic_path"        = "int"
  }

  # Generate the columns list of maps with name and type
  generated_columns = [
    for field in local.snake_case_fields : {
      name = field
      type = lookup(local.field_types, field, "string") # Defaults to "string" if type is not specified
    }
  ]
}

output "generated_columns" {
  value = local.generated_columns
}


# resource "aws_flow_log" "spoke_one_extended_accept" {
#   log_destination      = "${module.flow_logs.bucket_arn}/vpc-logs-parquet-extended/"
#   log_destination_type = "s3"
#   traffic_type         = "ACCEPT"
#   vpc_id               = module.spoke_one.vpc_attributes.id
#   log_format           = local.log_format
#   destination_options {
#     file_format        = "parquet"
#     per_hour_partition = true
#   }
# }

# resource "aws_flow_log" "spoke_one_extended_reject" {
#   log_destination      = "${module.flow_logs.bucket_arn}/vpc-logs-parquet-extended/"
#   log_destination_type = "s3"
#   traffic_type         = "REJECT"
#   vpc_id               = module.spoke_one.vpc_attributes.id
#   log_format           = local.log_format
#   destination_options {
#     file_format        = "parquet"
#     per_hour_partition = true
#   }
# }

# Glue Database
module "glue_catalog_database_extended" {
  source = "cloudposse/glue/aws//modules/glue-catalog-database"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  catalog_database_name        = "vpc-flow-logs-extended"
  catalog_database_description = "Glue Catalog database for the extened data located in ${local.extended_data_source}"
  location_uri                 = local.extended_data_source
}

module "glue_catalog_table_extended" {
  source = "cloudposse/glue/aws//modules/glue-catalog-table"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"

  catalog_table_name        = "vpc-flow-logs-extended"
  catalog_table_description = "vpc flow logs Glue Catalog table"
  database_name             = module.glue_catalog_database_extended.name
  table_type                = "EXTERNAL_TABLE"
  retention                 = 0
  owner                     = "owner"
  parameters                = local.parameters
  partition_keys            = local.partition_keys
  partition_index           = local.partition_index

  storage_descriptor = {
    additional_locations      = []
    bucket_columns            = []
    stored_as_sub_directories = false
    compressed                = false
    input_format              = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    location                  = local.extended_data_source
    number_of_buckets         = -1
    output_format             = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    parameters = {
      "classification"              = "parquet"
      "compressionType"             = "none"
      "partition_filtering.enabled" = "true"
      "typeOfData"                  = "file"
    }
    ser_de_info = {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = "1"
      }
      name = null
    }

    # Configuration block for columns in the table
    columns = local.generated_columns
  }
}

module "glue_crawler_extended" {
  source              = "cloudposse/glue/aws//modules/glue-crawler"
  crawler_name        = "vpc-flow-logs-extended-crawler"
  crawler_description = "Glue crawler that processes data in ${local.extended_data_source} and writes the metadata into a Glue Catalog database"
  database_name       = module.glue_catalog_database_extended.name
  role                = module.glue_role.iam_role_arn

  schema_change_policy = {
    delete_behavior = "LOG"
    update_behavior = "LOG"
  }

  catalog_target = [
    {
      database_name = module.glue_catalog_database_extended.name
      tables        = [module.glue_catalog_table_extended.name]
    }
  ]


  configuration = jsonencode(
    {
      CrawlerOutput = {
        Partitions = {
          AddOrUpdateBehavior = "InheritFromTable"
        }
      }
      Version = 1.0
    }
  )
}

resource "aws_athena_named_query" "rejected_traffic" {
  name        = "VpcFlowLogsRejectedTraffic"
  description = "Recorded traffic which was not permitted by the security groups or network ACLs."
  database    = module.glue_catalog_database.name
  query       = <<-EOT
    SELECT srcaddr, dstaddr, count(*) as count, "action"
    FROM "${module.glue_catalog_table_extended.name}
    WHERE "action" = 'REJECT'
    GROUP BY srcaddr, dstaddr, "action"
    ORDER BY count DESC
    LIMIT 25
  EOT
  workgroup   = aws_athena_workgroup.this.name
}


resource "aws_athena_named_query" "list_partitions" {
  name        = "VpcFlowLogsExrtendedListPartitions"
  description = "List most recent partitions in the vpc-flow-logs-extended table"
  database    = module.glue_catalog_database_extended.name
  query       = <<-EOT
    SELECT *
    FROM "${module.glue_catalog_database_extended.name}"."${module.glue_catalog_table_extended.name}$partitions"
    LIMIT 25
  EOT
  workgroup   = aws_athena_workgroup.this.name
}

resource "aws_athena_named_query" "top_srcaddr_hour" {
  name        = "VpcFlowLogsExrtendedListPartitions"
  description = "Display the top 10 source IP addresses by the total number of network packets over the past hour"
  database    = module.glue_catalog_database_extended.name
  query       = <<-EOT
    SELECT srcaddr, sum(packets) as num_packets
    FROM "${module.glue_catalog_database_extended.name}"."${module.glue_catalog_table_extended.name}$"
    WHERE FROM_UNIXTIME(start) > CURRENT_TIMESTAMP - INTERVAL '1' HOUR
    GROUP BY srcaddr
    LIMIT 10;
  EOT
  workgroup   = aws_athena_workgroup.this.name
}
