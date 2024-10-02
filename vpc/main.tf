
data "aws_region" "this" {}

data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  region = data.aws_region.this.name

  #TODO: check if IPAM is enabled, and get cidr block from IPAM
  vpc_cidr_block = var.ipv4_cidr_block

  existing_az_count = var.max_zones != null ? var.max_zones : length(data.aws_availability_zones.available.zone_ids)

  networks = var.networks

  default_resources_tags = {
    Type  = "vpc-default"
    Usage = "default do not use"
  }

}

# create the VPC, TODO: add more options
resource "aws_vpc" "default" {
  cidr_block                           = var.ipv4_cidr_block
  ipv4_ipam_pool_id                    = try(var.ipv4_cidr_block_association.ipv4_ipam_pool_id, null)
  ipv4_netmask_length                  = try(var.ipv4_cidr_block_association.ipv4_netmask_length, null)
  instance_tenancy                     = var.instance_tenancy
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_dns_support                   = var.enable_dns_support
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

#TODO: add more options, dhcp options, etc

####################################################################
# Take Control Over Default AWS Created Resources
####################################################################

# If `aws_default_security_group` is not defined, it will be created implicitly with access `0.0.0.0/0`
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id
  tags = merge(local.default_resources_tags, {
    Name = "${var.name_prefix}-sg-default"
  })
}

# If `aws_default_route_table` is not defined, it will be created implicitly with default routes
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.default.default_route_table_id
  tags = merge(local.default_resources_tags, {
    Name = "${var.name_prefix}-rtb-default"
  })
}

# If `aws_default_network_acl` is not defined, it will be created implicitly with access `0.0.0.0/0`
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.default.default_network_acl_id
  tags = merge(local.default_resources_tags, {
    Name = "${var.name_prefix}-nacl-default"
  })

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

#TODO: dont work if VPC is already created, check this behavior
# # If `aws_default_vpc_dhcp_options` is not defined, it will be created implicitly with default options
# resource "aws_default_vpc_dhcp_options" "default" {
#   tags = local.default_resources_tags
# }

#################################################################### 
# Network Calculation
#
# Important If the number of networks and requested netmasks per subnet is greater than the total available network space of the vpc_cidr_block, you need to adjust the number of networks to create. 
# error: "Invalid value for 'newbits' parameter: not enough remaining address space for a subnet with a prefix of 26 bits after 10.0.0.64/26."
#
####################################################################

locals {

  az_to_use = slice(data.aws_availability_zones.available.zone_ids, 0, local.existing_az_count)

  cidr_netmask = tonumber(split("/", local.vpc_cidr_block)[1])

  # multiply the number of networks by the number of zones to get the total number of subnets to create, while also calculating the new bits for each subnet. (Important: this needs to produce a list, to ensure ordering is preserved)
  networks_netmask_to_bits = flatten([for idx, network in local.networks : [for _, zone in local.az_to_use : {
    "name"     = format("%s-%s", network.name, zone),
    "zone"     = zone,
    "new_bits" = tonumber(network.netmask - local.cidr_netmask)
    "group"    = network.name,
    # "access_rule" = network.access_rule
    # "allow"       = network.allow
    }]
  ])

  # calculate the cidr blocks for every subnet based on the new bits
  cidr_by_bits = cidrsubnets(local.vpc_cidr_block, local.networks_netmask_to_bits[*].new_bits...)

  # create a list of network objects to pass to the subnet module
  network_objs = [for i, n in local.networks_netmask_to_bits : {
    name                 = n.name
    availability_zone_id = n.zone
    cidr_block           = n.name != null ? local.cidr_by_bits[i] : tostring(null)
    group                = n.group
    # access_rule          = n.access_rule
    # allow                = n.allow
  }]

  # create a map of network name to cidr block for easy lookup
  cidr_by_name = { for i, n in local.networks_netmask_to_bits : n.name => local.cidr_by_bits[i] if n.name != null }

  # create a map of network group to cidr block for easy lookup
  cidr_by_group = { for group in distinct([for subnet in local.networks_netmask_to_bits : subnet.group]) : group => [for subnet in local.network_objs : subnet.cidr_block if subnet.group == group]

  }

}

module "subnet" {
  source = "./subnet"

  for_each = { for idx, subnet in local.network_objs : local.network_objs[idx].name => subnet }

  name                 = format("%s-%s", var.name_prefix, each.value.name)
  vpc_id               = aws_vpc.default.id
  availability_zone_id = each.value.availability_zone_id
  cidr_block           = each.value.cidr_block

  tags = merge(var.tags, {
    Class = each.value.group
  })
}

locals {
  subnets_to_create = local.network_objs

  subnets_created = { for key, value in module.subnet : key => {
    name                 = value.name
    id                   = value.id
    cidr_block           = value.cidr_block
    route_table_id       = value.route_table_id
    availability_zone_id = value.availability_zone_id
  } }

  subnets_by_group = {
    for group in distinct([for subnet in local.subnets_to_create : subnet.group]) : group => [
      for name, details in local.subnets_created : details
      if contains([for subnet in local.subnets_to_create : subnet.name if subnet.group == group], name)
    ]
  }


  #TODO: create a more complex access rule object, allowing for more complex rules
  # such as allowing or denying broad access to/from specific groups

  # generate a map of access rules by groups and subnet
  # subnets_by_group_with_rule = {
  #   for group in distinct([for subnet in local.subnets_to_create : subnet.group]) : group => [
  #     for name, details in local.subnets_created : {
  #       name = name
  #       id   = details.id
  #       # grab the access rule from the first subnet in the group, set default to deny
  #       access_rule = element(distinct([for subnet in local.subnets_to_create : subnet.access_rule != null ? subnet.access_rule : "deny" if subnet.group == group]), 0)
  #     }
  #     if contains([for subnet in local.subnets_to_create : subnet.name if subnet.group == group], name)
  #   ]
  # }

  # nacl_rules_network_objs = [for index, network in local.network_objs : {
  #   group      = network.group
  #   cidr_block = network.cidr_block
  #   allowed_groups = {
  #     groups = network.allow
  #     cidrs  = flatten([for i, v in network.allow : [for p in local.network_objs : p.cidr_block if p.group == v]])
  #   }
  # }]
}

output "allowed_subnets" {
  value = local.cidr_by_group
}

module "nacl" {
  source = "./nacl"

  for_each = local.subnets_by_group

  name       = format("%s-%s-nacl", var.name_prefix, each.key)
  vpc_id     = aws_vpc.default.id
  subnet_ids = [for i, v in each.value : v.id]
  # access_rule = lookup(element(each.value, 0), "access_rule")
  tags = merge(var.tags, {
    Class = each.key
  })
}

output "nacls" {
  value = module.nacl
}