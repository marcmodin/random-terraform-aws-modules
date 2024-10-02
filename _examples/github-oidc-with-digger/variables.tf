variable "region" {
  type        = string
  default     = "eu-north-1"
  description = "The AWS region to deploy the resources"
}


variable "name_prefix" {
  type        = string
  description = "The name prefix to be used for all resources"
  default     = "aft"
}

variable "github_username" {
  type        = string
  description = "The GitHub username to grant access to"
}

variable "github_repositories" {
  type        = list(string)
  description = "The list of GitHub repositories to grant access to"
}