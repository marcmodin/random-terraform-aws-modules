
locals {
  log_format = "$${version} $${resource-type} $${account-id} $${tgw-id} $${tgw-attachment-id} $${tgw-src-vpc-account-id} $${tgw-dst-vpc-account-id} $${tgw-src-vpc-id} $${tgw-dst-vpc-id} $${tgw-src-subnet-id} $${tgw-dst-subnet-id} $${tgw-src-eni} $${tgw-dst-eni} $${tgw-src-az-id} $${tgw-dst-az-id} $${tgw-pair-attachment-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${log-status} $${type} $${packets-lost-no-route} $${packets-lost-blackhole} $${packets-lost-mtu-exceeded} $${packets-lost-ttl-expired} $${tcp-flags} $${region} $${flow-direction} $${pkt-src-aws-service} $${pkt-dst-aws-service}"


  # Split the log_format into individual fields by space
  raw_fields = split(" ", local.log_format)

  # Extract field names by removing the surrounding '$${' and '}' from each field
  extracted_fields = [for field in local.raw_fields : replace(replace(field, "$${", ""), "}", "")]

  # Convert kebab-case field names to snake_case for Terraform compatibility
  snake_case_fields = [for field in local.extracted_fields : replace(field, "-", "_")]

  # Define a mapping of field names to their respective data types
  # Adjust the types as necessary based on your specific requirements
  field_types = {
    "version"                   = "int"
    "resource-type"             = "string"
    "account-id"                = "string"
    "tgw-id"                    = "string"
    "tgw-attachment-id"         = "string"
    "tgw-src-vpc-account-id"    = "string"
    "tgw-dst-vpc-account-id"    = "string"
    "tgw-src-vpc-id"            = "string"
    "tgw-dst-vpc-id"            = "string"
    "tgw-src-subnet-id"         = "string"
    "tgw-dst-subnet-id"         = "string"
    "tgw-src-eni"               = "string"
    "tgw-dst-eni"               = "string"
    "tgw-src-az-id"             = "string"
    "tgw-dst-az-id"             = "string"
    "tgw-pair-attachment-id"    = "string"
    "srcaddr"                   = "string"
    "dstaddr"                   = "string"
    "srcport"                   = "int"
    "dstport"                   = "int"
    "protocol"                  = "int"
    "packets"                   = "int"
    "bytes"                     = "int"
    "start"                     = "int"
    "end"                       = "int"
    "log-status"                = "string"
    "type"                      = "string"
    "packets-lost-no-route"     = "int"
    "packets-lost-blackhole"    = "int"
    "packets-lost-mtu-exceeded" = "int"
    "packets-lost-ttl-expired"  = "int"
    "tcp-flags"                 = "int"
    "region"                    = "string"
    "flow-direction"            = "string"
    "pkt-src-aws-service"       = "string"
    "pkt-dst-aws-service"       = "string"
  }


  # Generate the columns list of maps with name and type
  generated_columns = [
    for field in local.snake_case_fields : {
      name = field
      type = lookup(local.field_types, field, "string") # Defaults to "string" if type is not specified
    }
  ]
}

################################################
# Create Test S3 bucket to store the flow logs
################################################

module "logs_bucket" {
  source                  = "cloudposse/s3-log-storage/aws"
  version                 = "1.4.3"
  bucket_name             = format("%s-logstorage-%s", var.name_prefix, local.account_id)
  sse_algorithm           = "AES256"
  allow_ssl_requests_only = true
  force_destroy           = false
  s3_object_ownership     = "BucketOwnerEnforced"
  versioning_enabled      = false
  lifecycle_rule_enabled  = false
}

################################################
# Create IAM Role and Policy for Firehose
################################################

data "aws_iam_policy_document" "firehose_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose" {
  name               = format("%s_firehose-delivery", var.name_prefix)
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
}

resource "aws_iam_role_policy" "firehose" {
  name   = "firehose"
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose.json
}


data "aws_iam_policy_document" "firehose" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:GetLogDelivery",
      "firehose:TagDeliveryStream",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [module.logs_bucket.bucket_arn, format("%s/*", module.logs_bucket.bucket_arn)]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]

    resources = [module.lambda.lambda_function_qualified_arn]
  }
}

################################################
# Create Kinesis Firehose Delivery Stream
################################################

resource "aws_kinesis_firehose_delivery_stream" "default" {
  name        = format("%s-delivery-stream", var.name_prefix)
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = module.logs_bucket.bucket_arn

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${module.lambda.lambda_function_arn}:$LATEST"
        }
      }
    }
  }

  tags = {
    "LogDeliveryEnabled" = "true"
  }
}

################################################
# Create Transit Gateway Flow Logs
################################################

# resource "aws_flow_log" "default" {
#   log_destination          = aws_kinesis_firehose_delivery_stream.default.arn
#   log_destination_type     = "kinesis-data-firehose"
#   log_format               = local.log_format
#   traffic_type             = "ALL"
#   transit_gateway_id       = module.transit_gateway.id
#   max_aggregation_interval = 60
#   tags = {
#     Name = format("%s-firehose", var.name_prefix)
#   }
# }