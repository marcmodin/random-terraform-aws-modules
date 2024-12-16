module "security_lake" {
  source = "../../security_lake"
  # replication_configuration_regions = ["eu-north-1"]

  aws_log_sources    = ["VPC_FLOW"]

  # subscribers = {
  #   "network-admin" = {
  #     access_type = "LAKEFORMATION"
  #     sources = [
  #       {
  #         source_name    = "VPC_FLOW"
  #         source_version = "2.0"
  #       }
  #     ]
  #     subscriber_identity = {
  #       external_id = ""
  #       principal   = ""
  #     }
  #   }
  # }
}

output "security_lake_arn" {
  value = module.security_lake
}