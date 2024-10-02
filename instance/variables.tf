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