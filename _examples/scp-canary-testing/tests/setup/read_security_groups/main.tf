
variable "region" {
  default = "eu-west-1"
}

variable "assumable_role_arn" {
  description = "The ARN of the role to assume"
  type        = string
}

# Provider for denied regions
provider "aws" {
  region = var.region

  assume_role {
    role_arn     = var.assumable_role_arn
    session_name = "terraform_test_session"
  }
}

data "aws_security_groups" "default" {}
