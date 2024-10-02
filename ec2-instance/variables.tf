
variable "name" {
  type        = string
  description = "name of the ec2 instance"
}

variable "ami_id" {
  type        = string
  description = "the ami id as a string"
}

variable "instance_type" {
  type        = string
  description = "the instance type"
}

variable "instance_profile" {
  type        = string
  description = "the instance profile to attach"
  default     = null
}

variable "subnet_id" {
  type        = any
  description = "subnet by id where to launch instance into"
  default     = null
}

variable "key_name" {
  type        = string
  description = "instance key pair name"
  default     = null
}

variable "tags" {
  type        = any
  description = "additional tags other than tag:Name, which is added by default"
  default     = {}
}

# sg
variable "vpc_id" {
  type        = string
  description = "vpc id used to attach default security group to"
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "attach security group/s"
  default     = []
}

variable "enable_termination_protection" {
  type        = bool
  description = "(optional) describe your variable"
  default     = false
}

variable "monitoring" {
  type        = bool
  description = "launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

