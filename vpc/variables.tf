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

variable "enable_flow_log" {
  type        = bool
  description = "Enable flow logs for the VPC. Requires `flow_log_configuration.log_destination`."
  default     = false

  validation {
    condition     = var.enable_flow_log == false || var.flow_log_configuration != null
    error_message = "flow_log_configuration must be set when enable_flow_log is true"
  }
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

variable "ipv4_netmask_length" {
  description = "Set to use IPAM to get an IPv4 CIDR block using a specified netmask. Must be set with `var.ipv4_ipam_pool_id`."
  type        = string
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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}



variable "flow_log_configuration" {
  type = object({
    log_format               = optional(string, "$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}")
    log_destination          = optional(string)
    traffic_type             = optional(string, "ALL")
    max_aggregation_interval = optional(number, 600)
    destination_options = optional(object({
      file_format                = optional(string, "plain-text")
      per_hour_partition         = optional(bool, false)
      hive_compatible_partitions = optional(bool, false)
    }))
  })

  default = null

}

variable "networks" {
  type = list(object({
    name    = string
    netmask = number
  }))

  description = <<EOT
A list of objects describing the requested subnetwork prefixes. Each object in the list defines a subnet group with specific attributes. 

- **name** (`string`): 
  - **Description**: The name of the subnet group. This identifier is used to reference the subnet group within your configuration.
  - **Example**: `"management"`, `"middleware"`
  
- **netmask** (`number`): 
  - **Description**: The netmask to slice from the `base_cidr_block`. This value is used to calculate the CIDR block dynamically for each subnet group.
  - **Example**: `28` (which corresponds to a `/28` CIDR block)

**Default**: `[]` (An empty list, meaning no subnet groups are defined by default)

**Example Usage**:

```
networks = [
  # Networks are created in the order they are defined. Always prefer to create the management network first.
  {
    name    = "management" # The name of the subnet group
    netmask = 28           # The netmask to slice from the base_cidr_block used to calculate the CIDR block dynamically
  },
  {
    name    = "middleware" # The name of the subnet group
    netmask = 28           # The netmask to slice from the base_cidr_block used to calculate the CIDR block dynamically
  },
] 
```
EOT
}

variable "network_acls" {
  type = map(object({
    ingress = list(object({
      action     = string
      number     = number
      cidr_block = string
      from_port  = number
      to_port    = number
      protocol   = string
    }))
    egress = list(object({
      action     = string
      number     = number
      cidr_block = string
      from_port  = number
      to_port    = number
      protocol   = string
    }))
  }))

  default     = {}
  description = <<EOT
**network_acls**

A map defining Network ACL rules for subnets.

- **ingress**: List of ingress rules.
  - **action**: "allow" or "deny".
  - **number**: Rule evaluation order.
  - **cidr_block**: CIDR block for the rule.
  - **from_port**: Starting port.
  - **to_port**: Ending port.
  - **protocol**: Protocol type (e.g., "tcp").

- **egress**: List of egress rules.
  - **action**: "allow" or "deny".
  - **number**: Rule evaluation order.
  - **cidr_block**: CIDR block for the rule.
  - **from_port**: Starting port.
  - **to_port**: Ending port.
  - **protocol**: Protocol type (e.g., "tcp").

**Example**:
```hcl
network_acls = {
  management = {
    ingress = [
      {
        number     = 120
        protocol   = "icmp"
        action     = "deny"
        from_port  = -1
        to_port    = -1
        cidr_block = "10.0.0.0/8"
      }
    ]
    egress = [
      {
        number     = 120
        protocol   = "icmp"
        action     = "deny"
        from_port  = -1
        to_port    = -1
        cidr_block = "10.0.0.0/8"
      }
    ]
  }
}
```
EOT
}

variable "transit_gateway_association" {
  type = object({
    id                                 = string
    subnet_group                       = string
    security_group_referencing_support = optional(string, "enable")
    dns_support                        = optional(string, "enable")
    appliance_mode_support             = optional(string, "disable")
    default_route_table_association    = optional(bool, true)
    default_route_table_propagation    = optional(bool, true)
    default_transit_gateway_route      = optional(string, "0.0.0.0/0")
    association_route_table_id         = optional(string, null)
    propagation_route_table_id         = optional(string, null)
  })

  description = <<EOT
This variable defines the configuration for the Transit Gateway Attachment with various settings.

- **id** (`string`): The unique identifier of the Transit Gateway to create an attachment for.
- **subnet_group** (`string`): The name the subnet group to associate with the Transit Gateway Attachment.
- **security_group_referencing_support** (`optional(string, "disable")`): 
  - **Description**: Enables or disables support for cross VPC referencing security groups.
  - **Default**: "disable"
- **dns_support** (`optional(string, "disable")`): 
  - **Description**: Enables or disables DNS support on the Transit Gateway Attachment.
  - **Default**: "disable"
- **appliance_mode_support** (`optional(string, "disable")`): 
  - **Description**: Enables or disables appliance mode support, which allows for integration with third-party appliances.
  - **Default**: "disable"
- **default_route_table_association** (`optional(bool, true)`): 
  - **Description**: Specifies whether to associate the default route table with the Transit Gateway Attachment. Set it to false if you need to manage this outside of the module.
  - **Default**: `true`
- **default_route_table_propagation** (`optional(bool, true)`): 
  - **Description**: Specifies whether to propagate routes to the default route table of the Transit Gateway Attachement. Set it to false if you need to manage this outside of the module.
  - **Default**: `true`
- **default_transit_gateway_route** (`optional(string, "0.0.0.0/0")`): 
  - **Description**: Defines the default route to Transit Gateway on all route-tables.
  - **Default**: "0.0.0.0/0"
- **association_route_table_id** (`optional(string, null)`): 
  - **Description**: The ID of the specific route table to associate with the Transit Gateway Attachment. If not provided, the default route table is used. Use this to override the default route table association.
  - **Default**: `null`
- **propagation_route_table_id** (`optional(string, null)`): 
  - **Description**: The ID of the specific route table to propagate routes to from the Transit Gateway. If not provided, the default route table is used. Use this to override the default route table association.
  - **Default**: `null`
EOT

  default = null
}

