
module "vpc" {
  source      = "../../vpc"
  name_prefix = var.name_prefix
  ipv4_cidr_block = "172.31.0.128/25"
  max_zones = 2
  networks = [
    {
      name    = "backend"
      netmask = 28
    },
    {
      name    = "middleware"
      netmask = 28
    },
    {
      name    = "frontend"
      netmask = 28
    }
  ]
}