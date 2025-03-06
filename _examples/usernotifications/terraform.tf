terraform {
  required_providers {
    awscc = {
      source = "hashicorp/awscc"
      version = "1.31.0"
    }
  }
}

provider "awscc" {
  region = "us-east-1"
}
