## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_default_route_table_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_default_route_table_association) | resource |
| [aws_ec2_transit_gateway_default_route_table_propagation.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_default_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ram_principal_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | Private Autonomous System Number (ASN) for the Amazon side of a BGP session. The range is 64512 to 65534 | `number` | `64512` | no |
| <a name="input_auto_accept_shared_attachments"></a> [auto\_accept\_shared\_attachments](#input\_auto\_accept\_shared\_attachments) | Whether resource attachment requests are automatically accepted. Valid values: `disable`, `enable`. Default value: `disable` | `string` | `"enable"` | no |
| <a name="input_create_route_tables"></a> [create\_route\_tables](#input\_create\_route\_tables) | Create route tables or not | `bool` | `true` | no |
| <a name="input_default_route_table_association"></a> [default\_route\_table\_association](#input\_default\_route\_table\_association) | Whether resource attachments are automatically associated with the default association route table. Valid values: `disable`, `enable`. Default value: `enable`. When enabled, a default route-tables will be created. Forces replacement if changed | `string` | `null` | no |
| <a name="input_default_route_table_propagation"></a> [default\_route\_table\_propagation](#input\_default\_route\_table\_propagation) | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`. Forces replacement if changed | `string` | `null` | no |
| <a name="input_dns_support"></a> [dns\_support](#input\_dns\_support) | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"enable"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to apply to all resources. | `string` | n/a | yes |
| <a name="input_resource_share_principals"></a> [resource\_share\_principals](#input\_resource\_share\_principals) | A list of principals to associate with the resource share. Possible values are an AWS account ID, an AWS Organizations Organization ARN, or an AWS Organizations Organization Unit ARN. | `list(string)` | `[]` | no |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | A map of route tables to create. The key is the name of the route table and the value is a map of options:<br/>  - default\_table: (Optional) Whether this is the default association route table. Default is false. You can only create one default association route table.<br/>  - default\_propagation: (Optional) Whether this is the default propagation route table. Default is false. You can only create one default propagation route table. | <pre>map(object({<br/>    default_table       = optional(bool, false) # this works, but is not used<br/>    default_propagation = optional(bool, false) # this works, but is not used<br/>  }))</pre> | `{}` | no |
| <a name="input_security_group_referencing_support"></a> [security\_group\_referencing\_support](#input\_security\_group\_referencing\_support) | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"enable"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | `{}` | no |
| <a name="input_vpn_ecmp_support"></a> [vpn\_ecmp\_support](#input\_vpn\_ecmp\_support) | Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable` | `string` | `"enable"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the Transit Gateway |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Transit Gateway |
| <a name="output_name"></a> [name](#output\_name) | The name of the Transit Gateway |
| <a name="output_region"></a> [region](#output\_region) | The region of the Transit Gateway |
| <a name="output_resource_share_principals"></a> [resource\_share\_principals](#output\_resource\_share\_principals) | The principals associated with the Transit Gateway resource share |
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | The IDs of the Transit Gateway route tables |
