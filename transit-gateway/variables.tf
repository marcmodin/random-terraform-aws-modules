# conditionals
variable "create_route_tables" {
  type        = bool
  default     = true
  description = "Create route tables or not"
}

# resources
variable "name_prefix" {
  type        = string
  description = "Prefix to apply to all resources. "
}

variable "amazon_side_asn" {
  type        = number
  description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session. The range is 64512 to 65534"
  default     = 64512
}

variable "auto_accept_shared_attachments" {
  type        = string
  default     = "enable"
  description = "Whether resource attachment requests are automatically accepted. Valid values: `disable`, `enable`. Default value: `disable`"
}

variable "default_route_table_association" {
  type        = string
  default     = null
  description = "Whether resource attachments are automatically associated with the default association route table. Valid values: `disable`, `enable`. Default value: `enable`. When enabled, a default route-tables will be created. Forces replacement if changed"
}

variable "default_route_table_propagation" {
  type        = string
  default     = null
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`. Forces replacement if changed"
}

variable "dns_support" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "vpn_ecmp_support" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "security_group_referencing_support" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "route_tables" {
  type = map(object({
    default_table       = optional(bool, false) # this works, but is not used
    default_propagation = optional(bool, false) # this works, but is not used
  }))

  default = {}

  description = <<EOT
  A map of route tables to create. The key is the name of the route table and the value is a map of options:
  - default_table: (Optional) Whether this is the default association route table. Default is false. You can only create one default association route table.
  - default_propagation: (Optional) Whether this is the default propagation route table. Default is false. You can only create one default propagation route table.
  EOT
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "resource_share_principals" {
  type        = list(string)
  default     = []
  description = "A list of principals to associate with the resource share. Possible values are an AWS account ID, an AWS Organizations Organization ARN, or an AWS Organizations Organization Unit ARN."
}