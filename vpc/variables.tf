variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_network_address_usage_metrics" {
  type        = bool
  description = "Enable network address usage metrics for the VPC"
  default     = false
}

variable "name_prefix" {
  type        = string
  description = "Prefix to apply to all resources. "
}

variable "ipv4_cidr_block" {
  type        = string
  description = "IPV4 CIDR block for the VPC. Conflicts with `ipv4_ipam_pool_id`. One of `ipv4_cidr_block` or `ipv4_ipam_pool_id` must be set."
  default     = null
}

variable "ipv4_ipam_pool_id" {
  type        = string
  description = "IPAM pool ID to use for the VPC. Conflicts with `ipv4_cidr_block`. One of `ipv4_cidr_block` or `ipv4_ipam_pool_id` must be set."
  default     = null
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC. Valid values are default or dedicated"
  default     = "default"
}

variable "max_zones" {
  type        = number
  description = "the number of availability zones to create subnets in. This determines the number of subnets to create. Defaults to current region availability zone count"
  default     = null

  validation {
    condition     = var.max_zones <= 3
    error_message = "max_zones must be equal to or less than 3"
  }
}

variable "networks" {
  type = list(object({
    name    = string
    netmask = number
  }))
  description = "A list of objects describing requested subnetwork prefixes. netmask is the requested subnetwork cidr to slice from base_cidr_block"
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}