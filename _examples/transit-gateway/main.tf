data "aws_organizations_organization" "org" {}

locals {
  this_root_ou           = data.aws_organizations_organization.org.id
  this_master_account_id = data.aws_organizations_organization.org.master_account_id
  ou_root_prefix         = format("arn:aws:organizations::%s:ou/%s/", local.this_master_account_id, local.this_root_ou)

  # a map of accounts and OUs to share the resource with (nested ou's need to be in format 'ou-xxxx-xxxxxxx/ou-xxxx-xxxxxxx')
  resource_share_principals = {
    accounts = [
      "000000000000",
    ]
    ous = [
      "ou-xxx-xxxxxxx",
    ]
  }

  resource_share_principals_cleaned = {
    accounts = local.resource_share_principals.accounts
    ous      = [for ou in local.resource_share_principals.ous : format("%s%s", local.ou_root_prefix, ou)]
  }

  resource_share_principals_merged = concat(local.resource_share_principals_cleaned.accounts, local.resource_share_principals_cleaned.ous)

}

output "resource_share_principals" {
  value = local.resource_share_principals_merged
}

module "transit_gateway" {
  source                          = "../../transit-gateway"
  name_prefix                     = format("%s-%s", var.name_prefix, var.region)
  amazon_side_asn                 = 64512
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  create_route_tables = true
  route_tables = {
    spokes     = {} # default_table = true dont work
    inspection = {} # default_propagation = true dont work
  }

  resource_share_principals = [] # local.resource_share_principals_merged

  tags = {
    Environment = "prod"
  }
}

output "transit_gateway" {
  value = module.transit_gateway
}

# # Find the pool RAM shared to your account
# # Info on RAM sharing pools: https://docs.aws.amazon.com/vpc/latest/ipam/share-pool-ipam.html
# data "aws_vpc_ipam_pools" "default" {
#   # filter {
#   #   name   = "description"
#   #   values = ["Production pool for the *"]
#   # }

#   filter {
#     name   = "tag:Environment"
#     values = ["prod"]
#   }

#   filter {
#     name   = "address-family"
#     values = ["ipv4"]
#   }

#   filter {
#     name   = "locale"
#     values = [var.region]
#   }

#   depends_on = [module.ipam-aws]
# }

# locals {
#   pools = {
#     for value in data.aws_vpc_ipam_pools.default.ipam_pools : value.locale => value.id
#   }
# }


# resource "aws_vpc_ipam_pool_cidr_allocation" "transit_gateway_allocation" {
#   ipam_pool_id = values(local.pools)[0]
#   cidr         = "10.0.0.0/24"
#   depends_on   = [module.ipam-aws]
# }

# output "transit_gateway_allocation" {
#   value = aws_vpc_ipam_pool_cidr_allocation.transit_gateway_allocation
# }