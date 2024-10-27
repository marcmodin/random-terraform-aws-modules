variable "region" {
  type        = string
  default     = "eu-north-1"
  description = "The AWS region to deploy the resources"
}


variable "name_prefix" {
  type        = string
  description = "The name prefix to be used for all resources"
  default     = "tgw"
}