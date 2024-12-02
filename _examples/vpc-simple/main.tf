
data "aws_caller_identity" "this" {}


# Centralized flow log destination
module "flow_logs" {
  source                  = "cloudposse/vpc-flow-logs-s3-bucket/aws"
  version                 = "1.3.0"
  bucket_name             = format("%s-flow-logs-%s", var.name_prefix, data.aws_caller_identity.this.account_id)
  bucket_key_enabled      = true
  force_destroy           = true
  flow_log_enabled        = false
  allow_ssl_requests_only = true
}

module "vpc" {
  source          = "../../vpc"
  name_prefix     = var.name_prefix
  enable_flow_log = true
  ipv4_cidr_block = "172.31.0.128/25"
  max_zones       = 2
  networks = [
    {
      name    = "backend"
      netmask = 28
    },
    {
      name    = "middleware"
      netmask = 28
    },
    {
      name    = "frontend"
      netmask = 28
    }
  ]

  flow_log_configuration = {
    log_destination = module.flow_logs.bucket_arn
    log_format      = "$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"
    destination_options = {
      file_format                = "parquet"
      per_hour_partition         = true
      hive_compatible_partitions = true
    }
  }

}