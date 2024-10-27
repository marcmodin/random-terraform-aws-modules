locals {
  # create a map of predefined subnets by type
  subnets_by_type = {
    egress = {
      public = {
        netmask                   = 28
        nat_gateway_configuration = var.nat_gateway_configuration # options: "multi_az", "single_az", "none"
      }
      # IPv4 only subnet
      management = {
        # omitting name_prefix defaults value to "private"
        name_prefix             = "management"
        netmask                 = 28
        connect_to_public_natgw = var.nat_gateway_configuration != "none" ? true : false
      }
      transit_gateway = {
        netmask                                         = 28
        transit_gateway_default_route_table_association = false
        transit_gateway_default_route_table_propagation = false
        connect_to_public_natgw = var.nat_gateway_configuration != "none" ? true : false
        transit_gateway_appliance_mode_support          = "disable"
        transit_gateway_dns_support                     = "enable"

        tags = {
          subnet_type = "tgw"
        }
      }
    },
    spoke = {
      # IPv4 only subnet
      middleware = {
        # omitting name_prefix defaults value to "private"
        name_prefix = "middleware"
        netmask     = 28
      }
      # IPv4 only subnet
      management = {
        # omitting name_prefix defaults value to "private"
        name_prefix = "management"
        netmask     = 28
      }
      transit_gateway = {
        netmask                                         = 28
        transit_gateway_default_route_table_association = true
        transit_gateway_default_route_table_propagation = true
        transit_gateway_dns_support                     = "enable"

        tags = {
          subnet_type = "tgw"
        }
      }
    }
  }

  # determine the type of subnet to create based on the network type
  subnets = try(local.subnets_by_type[var.network_type], null)

  # create a map of predefined transit gateway routes by type
  transit_gateway_routes_by_type = {
    egress = {
      public              = "10.0.0.0/8"
      management          = "10.0.0.0/8"
    }
    spoke = {
      management          = "0.0.0.0/0"
      middleware          = "0.0.0.0/0"
    }
  }
  # determine the type of transit gateway route to create based on the network type
  transit_gateway_routes = var.transit_gateway_id != null ? try(local.transit_gateway_routes_by_type[var.network_type], null) : {}

}