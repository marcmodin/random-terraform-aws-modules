variable "route_table_id" {
  type        = string
  description = "The oute table IDs to associate with the Transit Gateway"
}

variable "destination_cidr_block" {
  type        = string
  description = "The CIDR block of the route"
  default     = null
}

variable "destination_prefix_list_id" {
  type        = string
  description = "The prefix list ID of the route"
  default     = null
}

variable "transit_gateway_id" {
  type        = string
  description = "The ID of the Transit Gateway to associate with the route tables"
  default     = null
}

variable "core_network_arn" {
  type        = string
  description = "The ARN of the core network"
  default     = null
}

variable "gateway_id" {
  type        = string
  description = "The ID of a VPC internet gateway or a virtual private gateway. Specify `local` when updating a previously imported local route."
  default     = null
}

variable "nat_gateway_id" {
  type        = string
  description = "The ID of the NAT Gateway to associate with the route tables"
  default     = null
}

variable "vpc_endpoint_id" {
  type        = string
  description = "The ID of the VPC Endpoint to associate with the route tables"
  default     = null
}

# Create a route to the selected target on the given route table
resource "aws_route" "default" {
  route_table_id             = var.route_table_id
  destination_cidr_block     = var.destination_cidr_block
  destination_prefix_list_id = var.destination_prefix_list_id
  transit_gateway_id         = var.transit_gateway_id
  core_network_arn           = var.core_network_arn
  nat_gateway_id             = var.nat_gateway_id
  vpc_endpoint_id            = var.vpc_endpoint_id
  gateway_id                 = var.gateway_id

  timeouts {
    create = "5m"
  }
}