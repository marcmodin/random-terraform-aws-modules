terraform {
  required_version = ">= 1.2.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11.0, < 6.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "euc1"
  region = "eu-central-1"
}