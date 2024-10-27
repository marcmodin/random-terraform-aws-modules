# VPC Management Terraform Module

The VPC Management Terraform Module streamlines the creation and configuration of Amazon Virtual Private Clouds (VPCs) and their associated networking components.

This module facilitates the setup of customizable VPCs with dynamic CIDR blocks, multiple availability zones, and tailored subnet configurations for different network types such as egress and spoke. It integrates seamlessly with AWS Transit Gateway, allowing for scalable and flexible network routing based on specified network types.

Additionally, the module supports NAT gateway configurations and VPC flow logs for enhanced monitoring and security. By leveraging this module, users can efficiently deploy robust, secure, and well-organized network infrastructures that adhere to best practices in network segmentation and manageability.

# Module Inputs

## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_wrapper"></a> [wrapper](#module\_wrapper) | ./vpc_ai | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | The number of availability zones to use | `number` | `2` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | The CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the VPC | `string` | n/a | yes |
| <a name="input_nat_gateway_configuration"></a> [nat\_gateway\_configuration](#input\_nat\_gateway\_configuration) | The NAT gateway configuration. Options are 'multi\_az', 'single\_az', or 'none' | `string` | `"none"` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | The type of network to create. Options are 'egress', 'inspection', or 'spoke' | `string` | n/a | yes |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | The ID of the transit gateway to attach the VPC to | `string` | `null` | no |
| <a name="input_vpc_flow_logs_enabled"></a> [vpc\_flow\_logs\_enabled](#input\_vpc\_flow\_logs\_enabled) | Enable VPC flow logs | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | Attributes of private subnets grouped by availability zone. |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | Attributes of public subnets grouped by availability zone. |
| <a name="output_transit_gateway_attachment_id"></a> [transit\_gateway\_attachment\_id](#output\_transit\_gateway\_attachment\_id) | The ID of the Transit Gateway attachment, if configured. |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block assigned to the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The unique identifier of the VPC. |
