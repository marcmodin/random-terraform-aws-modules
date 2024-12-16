data "aws_region" "current" {}

locals {
  this_region = data.aws_region.current.name
}

resource "aws_securitylake_data_lake" "default" {
  meta_store_manager_role_arn = module.security_lake_meta_store_manager.iam_role_arn

  configuration {
    region = local.this_region

    dynamic "encryption_configuration" {
      for_each = var.encryption_configuration != null ? [true] : [false]
      content {
        kms_key_id = var.encryption_configuration.kms_key_id
      }
    }

    dynamic "lifecycle_configuration" {
      for_each = var.lifecycle_configuration != null ? [true] : [false]
      content {
        expiration {
          days = var.lifecycle_configuration.expiration.days
        }

        transition {
          days          = var.lifecycle_configuration.transition.days
          storage_class = var.lifecycle_configuration.transition.storage_class
        }
      }
    }

    dynamic "replication_configuration" {
      for_each = var.replication_configuration_regions != null ? [true] : []
      content {
        regions  = var.replication_configuration_regions
        role_arn = module.security_lake_replication_manager["true"].iam_role_arn
      }
    }
  }
}

resource "aws_securitylake_aws_log_source" "default" {
  for_each = toset(var.aws_log_sources)
  source {
    regions     = [local.this_region]
    source_name = each.value
  }
  depends_on = [aws_securitylake_data_lake.default]
}

resource "aws_securitylake_subscriber" "default" {
  for_each = var.subscribers

  subscriber_name = each.key
  subscriber_description = each.value.description
  access_type     = each.value.access_type

  dynamic "source" {
    # for_each = {for key, value in var.subscribers[each.key]: key => value if value == each.value}
    for_each = each.value.sources
    content {
      aws_log_source_resource {
        source_name    = source.value.source_name
        source_version = source.value.source_version
      }
    }
  }

  subscriber_identity {
    external_id = each.value.subscriber_identity.external_id
    principal   = each.value.subscriber_identity.principal
  }

  depends_on = [aws_securitylake_data_lake.default, aws_securitylake_aws_log_source.default]
}