variable "name" {
  type        = string
  description = "The name of the VPC"
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "az_count" {
  type        = number
  description = "The number of availability zones to use"
  default     = 2
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

variable "nat_gateway_configuration" {
  type        = string
  description = "The NAT gateway configuration. Options are 'multi_az', 'single_az', or 'none'"
  default     = "none"
}

variable "vpc_flow_logs_enabled" {
  type        = bool
  description = "Enable VPC flow logs"
  default     = false
}
