variable "name_prefix" {
  type        = string
  description = "The name prefix to use for all resources"
}

variable "project" {
  type        = string
  description = "The project of the VPC"
}

variable "environment" {
  type        = string
  description = "The environment of the VPC"
  default     = "dev"
}

variable "class" {
  type        = string
  description = "The class of the VPC"
  default     = "restricted"

  validation {
    condition     = can(regex("^(restricted|controlled|uncontrolled)$", var.class))
    error_message = "Class must be either 'restricted', 'controlled' or 'uncontrolled'"
  }
}

variable "network_type" {
  type        = string
  description = "The type of network to create. Options are 'egress', 'inspection', or 'spoke'"
}

variable "transit_gateway_id" {
  type        = string
  description = "The ID of the transit gateway to attach the VPC to"
  default     = null
}
