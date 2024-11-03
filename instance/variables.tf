variable "name_prefix" {
  type        = string
  description = "description"
}

variable "vpc_id" {
  type        = string
  description = "description"
}

variable "subnet_id" {
  type        = string
  description = "description"
}

variable "instance_type" {
  type        = string
  description = "description"
  default     = "t3.small"
}

variable "ami_name_filter" {
  type        = string
  description = "name filter for the ami, use wildcard for best results. eg. al2023-ami-2023* for amazon-linux or ubuntu/images/hvm-ssd-gp3/ubuntu-noble* for ubuntu"
  default     = "al2023-ami-2023*"
}

variable "ami_architecture" {
  type        = string
  description = "architecture of the ami. eg. x86_64, arm64"
  default     = "x86_64"
}

variable "monitoring" {
  type        = bool
  description = "detailed monitoring enabled"
  default     = false
}

variable "state" {
  type        = string
  description = "State of the instance. Valid values are stopped, running"
  default     = "running"
}