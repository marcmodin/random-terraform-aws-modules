output "vpc_id" {
  value = aws_vpc.default.id
}

output "vpc_arn" {
  value = aws_vpc.default.arn
}

output "vpc_cidr_block" {
  value = aws_vpc.default.cidr_block
}

output "vpc_default_route_table_id" {
  value = aws_vpc.default.default_route_table_id
}

output "vpc_default_network_acl_id" {
  value = aws_vpc.default.default_network_acl_id
}

output "vpc_default_security_group_id" {
  value = aws_vpc.default.default_security_group_id
}

output "vpc_dhcp_options_id" {
  value = aws_vpc.default.dhcp_options_id
}


# output "calc_subnets" {
#   value = local.network_objs
# }

# output "calc_subnets_cidr_by_name" {
#   value = local.cidr_by_name
# }


output "subnets" {
  value = local.subnets_created
}

output "subnets_by_group" {
  value = local.subnets_by_group

  description = "Subnets grouped by group name. Example usage: get a single id - [element(module.vpc.subnets_by_group.management, 0).id]"
}
