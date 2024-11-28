# Local mapping of full region names to shorthand region names
locals {
  region_map = {
    "af-south-1"     = "afs1" # Africa (Cape Town)
    "ap-east-1"      = "ape1" # Asia Pacific (Hong Kong)
    "ap-south-1"     = "aps1" # Asia Pacific (Mumbai)
    "ap-south-2"     = "aps2" # Asia Pacific (Hyderabad)
    "ap-southeast-1" = "apse1" # Asia Pacific (Singapore)
    "ap-southeast-2" = "apse2" # Asia Pacific (Sydney)
    "ap-northeast-1" = "apne1" # Asia Pacific (Tokyo)
    "ap-northeast-2" = "apne2" # Asia Pacific (Seoul)
    "ap-northeast-3" = "apne2" # Asia Pacific (Osaka)
    "ap-southeast-4" = "apse4" # Asia Pacific (Melbourne)
    "ca-central-1"  = "cac1" # Canada (Central)
    "ca-west-1"  = "caw1" # Canada West (Calgary)
    "eu-central-1"   = "euc1" # Europe (Frankfurt)
    "eu-central-2"   = "euc2" # Europe (Zurich)
    "eu-north-1"     = "eun1" # Europe (Stockholm)
    "eu-south-1"     = "eus1" # Europe (Milan)
    "eu-south-2"     = "eus2" # Europe (Milan)
    "eu-west-1"      = "euw1" # Europe (Ireland)
    "eu-west-2"      = "euw2" # Europe (London)
    "eu-west-3"      = "euw3" # Europe (Paris)
    "il-central-1"   = "ilc1" # Israel (Tel Aviv)
    "me-south-1"     = "mes1" # Middle East (Bahrain)
    "me-central-1"   = "mec1" # Middle East (UAE)
    "sa-east-1"      = "sae1" # South America (Sao Paulo)
    "us-east-1"      = "use1" # US East (N. Virginia)
    "us-east-2"      = "use2" # US East (Ohio)
    "us-west-1"      = "usw1" # US West (N. California)
    "us-west-2"      = "usw2" # US West (Oregon)

  }

  # Retrieve the shorthand region using the mapping
  short_region = lookup(local.region_map, var.region, null)
}