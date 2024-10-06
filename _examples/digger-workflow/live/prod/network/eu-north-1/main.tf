provider "aws" {
  region = "eu-north-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "this_account_id" {
  value = { "Network" = data.aws_caller_identity.current.account_id}
}

output "this_region" {
  value = data.aws_region.current.name
}