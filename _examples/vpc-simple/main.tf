
data "aws_caller_identity" "this" {}

# create an s3 bucket
resource "aws_s3_bucket" "flow_log_bucket" {
  bucket        = "flow-log-bucket-${data.aws_caller_identity.this.account_id}"
  force_destroy = true
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
    log_destination = aws_s3_bucket.flow_log_bucket.arn
    log_format      = "$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"
    destination_options = {
      file_format                = "parquet"
      per_hour_partition         = true
      hive_compatible_partitions = true
    }
  }

}