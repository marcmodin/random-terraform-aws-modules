# Creates a VPC attachment to a Transit Gateway per selected subnet. Also creates a route to the Transit Gateway in the selected route tables.

variable "transit_gateway_id" {
  type        = string
  description = "Identifier of EC2 Transit Gateway this vpc attachment belongs to"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to attach to the Transit Gateway"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of Identifiers of Subnets to create attachments in"
}

variable "appliance_mode_support" {
  type        = string
  description = " Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow"
  default     = "disable"
}

variable "default_route_table_association" {
  type        = bool
  default     = true
  description = "Whether resource attachments are automatically associated with the default association route table. Default value: `true`."
}

variable "default_route_table_propagation" {
  type        = bool
  default     = true
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Default value: `true`."
}

variable "association_route_table_id" {
  type        = string
  default     = null
  description = "The default association route table to associate with the attachment"
}

variable "propagation_route_table_id" {
  type        = string
  default     = null
  description = "The default propagation route table to propagate with the attachment"
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

variable "tags" {
  type        = map(any)
  description = "A map of tags to add to all resources"
}


resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = var.vpc_id
  subnet_ids                                      = var.subnet_ids
  appliance_mode_support                          = var.appliance_mode_support
  dns_support                                     = var.dns_support
  security_group_referencing_support              = var.security_group_referencing_support
  transit_gateway_default_route_table_association = var.default_route_table_association
  transit_gateway_default_route_table_propagation = var.default_route_table_propagation

  tags = var.tags

  # test if this works
  lifecycle {
    ignore_changes = [transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation]
  }
}

# Allow traffic from the VPC attachments to the Transit Gateway
resource "aws_ec2_transit_gateway_route_table_association" "default" {
  count                          = var.default_route_table_association ? 0 : 1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default.id
  transit_gateway_route_table_id = var.association_route_table_id
}

# Allow traffic from the Transit Gateway to the VPC attachments
# Propagations will create propagated routes
resource "aws_ec2_transit_gateway_route_table_propagation" "default" {
  count                          = var.default_route_table_propagation ? 0 : 1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default.id
  transit_gateway_route_table_id = var.propagation_route_table_id
}

output "id" {
  value = aws_ec2_transit_gateway_vpc_attachment.default.id
}