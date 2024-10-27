# Fetch the current AWS region
data "aws_region" "this" {}

# Local mapping of full region names to shorthand region names
locals {
  region_map = {
    "us-east-1"      = "use1"
    "us-east-2"      = "use2"
    "us-west-1"      = "usw1"
    "us-west-2"      = "usw2"
    "eu-west-1"      = "euw1"
    "eu-west-2"      = "euw2"
    "eu-west-3"      = "euw3"
    "eu-north-1"     = "eun1"
    "eu-south-1"     = "eus1"
    "ap-southeast-1" = "aps1"
    "ap-southeast-2" = "aps2"
    "ap-northeast-1" = "apn1"
    "ap-northeast-2" = "apn2"
    "ap-east-1"      = "ape1"
    "sa-east-1"      = "sae1"
    "ca-central-1"   = "cac1"
    "me-south-1"     = "mes1"
    "af-south-1"     = "afs1"
    "eu-central-1"   = "euc1"
    "eu-central-2"   = "euc2"
    # Add additional regions as needed
  }

  # Retrieve the shorthand region using the mapping
  short_region = lookup(local.region_map, data.aws_region.this.name, null)
}

output "short_region" {
  value = local.short_region
}

output "region" {
  value = data.aws_region.this.name
}

output "description" {
  value = data.aws_region.this.description
}