module "wrapper" {
  source   = "aws-ia/vpc/aws"
  version = ">= 4.2.0"

  name                   = var.name
  cidr_block             = var.cidr_block
  az_count               = var.az_count
  subnets                = local.subnets
  transit_gateway_id     = var.transit_gateway_id
  transit_gateway_routes = local.transit_gateway_routes

  vpc_flow_logs = var.vpc_flow_logs_enabled ? {
    log_destination_type = "cloud-watch-logs"
    retention_in_days    = 180
  } : { log_destination_type = "none" }
}