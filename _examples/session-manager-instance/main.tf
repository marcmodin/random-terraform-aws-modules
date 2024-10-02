
module "vpc" {
  source      = "../../vpc"
  name_prefix = var.name_prefix
  ipv4_cidr_block = "172.31.0.0/25"
  max_zones = 2
  networks = [
    {
      name    = "management"
      netmask = 28
    },
    {
      name    = "middleware"
      netmask = 28
    }
  ]
}

# Create a session manager endpoint
module "session_manager" {
  source = "../../session-manager"

  name_prefix    = var.name_prefix
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = [element(module.vpc.subnets_by_group.management, 0).id]
}

# Create an instance
module "instance" {
  source      = "../../instance"
  name_prefix = format("%s-instance", var.name_prefix)
  vpc_id      = module.vpc.vpc_id
  subnet_id   = element(module.vpc.subnets_by_group.middleware, 0).id
  # state       = "running"
}