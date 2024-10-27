# AWS Terraform Network Module

### Simple Subnet Table

| SUBNET RANGE | HOSTS * |
|--------------|---------|
| x.x.x.x/16   | 65531   |
| x.x.x.x/17   | 32763   |
| x.x.x.x/18   | 16379   |
| x.x.x.x/19   | 8187    |
| x.x.x.x/20   | 4091    |
| x.x.x.x/21   | 2043    |
| x.x.x.x/22   | 1019    |
| x.x.x.x/23   | 507     |
| x.x.x.x/24   | 251     |
| x.x.x.x/25   | 123     |
| x.x.x.x/26   | 59      |
| x.x.x.x/27   | 27      |
| x.x.x.x/28   | 11      |

# Module Inputs

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nacl"></a> [nacl](#module\_nacl) | ./nacl | n/a |
| <a name="module_nacl-rules"></a> [nacl-rules](#module\_nacl-rules) | ./nacl-rules | n/a |
| <a name="module_subnet"></a> [subnet](#module\_subnet) | ./subnet | n/a |
| <a name="module_tgw-attachment"></a> [tgw-attachment](#module\_tgw-attachment) | ./tgw-att | n/a |
| <a name="module_tgw-attachment-route"></a> [tgw-attachment-route](#module\_tgw-attachment-route) | ./route | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_default_network_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc_ipam_preview_next_cidr.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_ipam_preview_next_cidr) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_enable_network_address_usage_metrics"></a> [enable\_network\_address\_usage\_metrics](#input\_enable\_network\_address\_usage\_metrics) | Enable network address usage metrics for the VPC | `bool` | `false` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | A tenancy option for instances launched into the VPC. Valid values are default or dedicated | `string` | `"default"` | no |
| <a name="input_ipv4_cidr_block"></a> [ipv4\_cidr\_block](#input\_ipv4\_cidr\_block) | IPV4 CIDR block for the VPC. Conflicts with `ipv4_ipam_pool_id`. One of `ipv4_cidr_block` or `ipv4_ipam_pool_id` must be set. | `string` | `null` | no |
| <a name="input_ipv4_cidr_block_association"></a> [ipv4\_cidr\_block\_association](#input\_ipv4\_cidr\_block\_association) | Configuration of the VPC's primary IPv4 CIDR block via IPAM. Conflicts with `ipv4_cidr_block`.<br/>One of `ipv4_cidr_block` or `ipv4_cidr_block_association` must be set. | <pre>object({<br/>    ipv4_ipam_pool_id   = string<br/>    ipv4_netmask_length = optional(number, null)<br/>  })</pre> | `null` | no |
| <a name="input_ipv4_ipam_pool_id"></a> [ipv4\_ipam\_pool\_id](#input\_ipv4\_ipam\_pool\_id) | IPAM pool ID to use for the VPC. Conflicts with `ipv4_cidr_block`. One of `ipv4_cidr_block` or `ipv4_ipam_pool_id` must be set. | `string` | `null` | no |
| <a name="input_max_zones"></a> [max\_zones](#input\_max\_zones) | the number of availability zones to create subnets in. This determines the number of subnets to create. Defaults to current region availability zone count | `number` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to apply to all resources. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | **network\_acls**<br/><br/>A map defining Network ACL rules for subnets.<br/><br/>- **ingress**: List of ingress rules.<br/>  - **action**: "allow" or "deny".<br/>  - **number**: Rule evaluation order.<br/>  - **cidr\_block**: CIDR block for the rule.<br/>  - **from\_port**: Starting port.<br/>  - **to\_port**: Ending port.<br/>  - **protocol**: Protocol type (e.g., "tcp").<br/><br/>- **egress**: List of egress rules.<br/>  - **action**: "allow" or "deny".<br/>  - **number**: Rule evaluation order.<br/>  - **cidr\_block**: CIDR block for the rule.<br/>  - **from\_port**: Starting port.<br/>  - **to\_port**: Ending port.<br/>  - **protocol**: Protocol type (e.g., "tcp").<br/><br/>**Example**:<pre>hcl<br/>network_acls = {<br/>  management = {<br/>    ingress = [<br/>      {<br/>        number     = 120<br/>        protocol   = "icmp"<br/>        action     = "deny"<br/>        from_port  = -1<br/>        to_port    = -1<br/>        cidr_block = "10.0.0.0/8"<br/>      }<br/>    ]<br/>    egress = [<br/>      {<br/>        number     = 120<br/>        protocol   = "icmp"<br/>        action     = "deny"<br/>        from_port  = -1<br/>        to_port    = -1<br/>        cidr_block = "10.0.0.0/8"<br/>      }<br/>    ]<br/>  }<br/>}</pre> | <pre>map(object({<br/>    ingress = list(object({<br/>      action     = string<br/>      number     = number<br/>      cidr_block = string<br/>      from_port  = number<br/>      to_port    = number<br/>      protocol   = string<br/>    }))<br/>    egress = list(object({<br/>      action     = string<br/>      number     = number<br/>      cidr_block = string<br/>      from_port  = number<br/>      to_port    = number<br/>      protocol   = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | A list of objects describing the requested subnetwork prefixes. Each object in the list defines a subnet group with specific attributes. <br/><br/>- **name** (`string`): <br/>  - **Description**: The name of the subnet group. This identifier is used to reference the subnet group within your configuration.<br/>  - **Example**: `"management"`, `"middleware"`<br/><br/>- **netmask** (`number`): <br/>  - **Description**: The netmask to slice from the `base_cidr_block`. This value is used to calculate the CIDR block dynamically for each subnet group.<br/>  - **Example**: `28` (which corresponds to a `/28` CIDR block)<br/><br/>**Default**: `[]` (An empty list, meaning no subnet groups are defined by default)<br/><br/>**Example Usage**:<pre>networks = [<br/>  # Networks are created in the order they are defined. Always prefer to create the management network first.<br/>  {<br/>    name    = "management" # The name of the subnet group<br/>    netmask = 28           # The netmask to slice from the base_cidr_block used to calculate the CIDR block dynamically<br/>  },<br/>  {<br/>    name    = "middleware" # The name of the subnet group<br/>    netmask = 28           # The netmask to slice from the base_cidr_block used to calculate the CIDR block dynamically<br/>  },<br/>]</pre> | <pre>list(object({<br/>    name    = string<br/>    netmask = number<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_transit_gateway_association"></a> [transit\_gateway\_association](#input\_transit\_gateway\_association) | This variable defines the configuration for the Transit Gateway Attachment with various settings.<br/><br/>- **id** (`string`): The unique identifier of the Transit Gateway to create an attachment for.<br/>- **subnet\_group** (`string`): The name the subnet group to associate with the Transit Gateway Attachment.<br/>- **security\_group\_referencing\_support** (`optional(string, "disable")`): <br/>  - **Description**: Enables or disables support for cross VPC referencing security groups.<br/>  - **Default**: "disable"<br/>- **dns\_support** (`optional(string, "disable")`): <br/>  - **Description**: Enables or disables DNS support on the Transit Gateway Attachment.<br/>  - **Default**: "disable"<br/>- **appliance\_mode\_support** (`optional(string, "disable")`): <br/>  - **Description**: Enables or disables appliance mode support, which allows for integration with third-party appliances.<br/>  - **Default**: "disable"<br/>- **default\_route\_table\_association** (`optional(bool, true)`): <br/>  - **Description**: Specifies whether to associate the default route table with the Transit Gateway Attachment. Set it to false if you need to manage this outside of the module.<br/>  - **Default**: `true`<br/>- **default\_route\_table\_propagation** (`optional(bool, true)`): <br/>  - **Description**: Specifies whether to propagate routes to the default route table of the Transit Gateway Attachement. Set it to false if you need to manage this outside of the module.<br/>  - **Default**: `true`<br/>- **default\_transit\_gateway\_route** (`optional(string, "0.0.0.0/0")`): <br/>  - **Description**: Defines the default route to Transit Gateway on all route-tables.<br/>  - **Default**: "0.0.0.0/0"<br/>- **association\_route\_table\_id** (`optional(string, null)`): <br/>  - **Description**: The ID of the specific route table to associate with the Transit Gateway Attachment. If not provided, the default route table is used. Use this to override the default route table association.<br/>  - **Default**: `null`<br/>- **propagation\_route\_table\_id** (`optional(string, null)`): <br/>  - **Description**: The ID of the specific route table to propagate routes to from the Transit Gateway. If not provided, the default route table is used. Use this to override the default route table association.<br/>  - **Default**: `null` | <pre>object({<br/>    id                                 = string<br/>    subnet_group                       = string<br/>    security_group_referencing_support = optional(string, "disable")<br/>    dns_support                        = optional(string, "disable")<br/>    appliance_mode_support             = optional(string, "disable")<br/>    default_route_table_association    = optional(bool, true)<br/>    default_route_table_propagation    = optional(bool, true)<br/>    default_transit_gateway_route      = optional(string, "0.0.0.0/0")<br/>    association_route_table_id         = optional(string, null)<br/>    propagation_route_table_id         = optional(string, null)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nacl_rules"></a> [nacl\_rules](#output\_nacl\_rules) | A list of rules associated with the Network ACLs in the VPC. |
| <a name="output_nacls"></a> [nacls](#output\_nacls) | A list of Network ACLs created within the VPC. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | A list of subnets created within the VPC. |
| <a name="output_subnets_by_group"></a> [subnets\_by\_group](#output\_subnets\_by\_group) | Subnets grouped by group name. Example usage: get a single id - [element(module.vpc.subnets\_by\_group.management, 0).id] |
| <a name="output_transit_gateway_attachment"></a> [transit\_gateway\_attachment](#output\_transit\_gateway\_attachment) | Transit Gateway Attachment module output. |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The ARN of the default VPC. |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the default VPC. |
| <a name="output_vpc_default_network_acl_id"></a> [vpc\_default\_network\_acl\_id](#output\_vpc\_default\_network\_acl\_id) | The ID of the default Network ACL for the VPC. |
| <a name="output_vpc_default_route_table_id"></a> [vpc\_default\_route\_table\_id](#output\_vpc\_default\_route\_table\_id) | The ID of the default route table for the VPC. |
| <a name="output_vpc_default_security_group_id"></a> [vpc\_default\_security\_group\_id](#output\_vpc\_default\_security\_group\_id) | The ID of the default Security Group for the VPC. |
| <a name="output_vpc_dhcp_options_id"></a> [vpc\_dhcp\_options\_id](#output\_vpc\_dhcp\_options\_id) | The ID of the DHCP options set associated with the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The unique identifier of the default VPC. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name assigned to the default VPC. |
