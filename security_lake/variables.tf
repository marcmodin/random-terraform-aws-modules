variable "encryption_configuration" {
  type = object({
    kms_key_id = string
  })

  default = {
    kms_key_id = "S3_MANAGED_KEY"
  }

  description = "The encryption configuration for the Security Lake Data Lake"
}


variable "lifecycle_configuration" {
  type = object({
    expiration = optional(object({
      days = number
    }), null)

    transition = optional(object({
      days          = number
      storage_class = string
    }), null)
  })

  default = {
    expiration = {
      days = 365
    }

    transition = {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  description = "The lifecycle configuration for the Security Lake Data Lake"
}

# variable "enable_replication_configuration" {
#   type        = bool
#   default     = false
#   description = "Enable replication configuration for the Security Lake Data Lake"
# }

variable "replication_configuration_regions" {
  type        = list(string)
  default     = null
  description = "Replication enables automatic, asynchronous copying of objects across Amazon S3 buckets. Amazon S3 buckets that are configured for object replication can be owned by the same AWS account or by different accounts. You can replicate objects to a single destination bucket or to multiple destination buckets. The destination buckets can be in different AWS Regions or within the same Region as the source bucket"
}

variable "aws_log_sources" {
  type        = list(string)
  default     = []
  description = "The AWS log sources to be ingested into the Security Lake Data Lake. Valid values: ROUTE53, VPC_FLOW, SH_FINDINGS, CLOUD_TRAIL_MGMT, LAMBDA_EXECUTION, S3_DATA, EKS_AUDIT, WAF."

  # if the list is not empty, check if the value provided is a valid name
  validation {
    condition = (
      var.aws_log_sources == [] ||
      alltrue([
        for log_source in var.aws_log_sources : contains(local.valid_log_sources, log_source)
      ])
    )
    error_message = "Invalid AWS log source name(s) provided. Valid values are: ${join(", ", local.valid_log_sources)}."
  }
}

# handling log sources names

locals {
  valid_log_sources = [
    "ROUTE53",
    "VPC_FLOW",
    "SH_FINDINGS",
    "CLOUD_TRAIL_MGMT",
    "LAMBDA_EXECUTION",
    "S3_DATA",
    "EKS_AUDIT",
    "WAF"
  ]
}

variable "subscribers" {
  type = map(object({
    access_type = string
    description = optional(string, null)
    sources = list(object({
      source_name    = string
      source_version = string
    }))
    subscriber_identity = object({
      external_id = string
      principal   = string
    })
  }))

  default = {}

  description = "Map of subscriber configurations. Each key represents a unique subscriber."

  # validate that the subscriber_identity principal is a valid regex ^([0-9]{12}|[a-z0-9\.\-]*\.(amazonaws|amazon)\.com)$
  validation {
    condition = alltrue([
      for subscriber in var.subscribers : can(regex("^[0-9]{12}|[a-z0-9\\.-]*\\.(amazonaws|amazon)\\.com$", subscriber.subscriber_identity.principal))
    ])
    error_message = "Invalid principal provided in one or more subscribers. The principal must be a valid AWS account ID or an AWS service principal."
  }

  # validate that the access_type is either S3 or LAKEFORMATION
  validation {
    condition = alltrue([
      for subscriber in var.subscribers : contains(["S3", "LAKEFORMATION"], subscriber.access_type)
    ])
    error_message = "Invalid access_type provided in one or more subscribers. Valid values are: S3, LAKEFORMATION."
  }

  validation {
    condition = (
      # Allow empty map
      length(var.subscribers) == 0 ||
      # Ensure all source_names in all subscribers are valid
      alltrue([
        for subscriber in var.subscribers :
        alltrue([
          for src in subscriber.sources : contains(local.valid_log_sources, src.source_name)
        ])
      ])
    )
    error_message = "Invalid source_name provided in one or more subscribers. Valid values are: ${join(", ", local.valid_log_sources)}."
  }
}

# variable "custom_log_sources" {
#   type = list(object({
#     name    = string
#     regions = list(string)
#   }))

#   default     = []
#   description = "The custom log sources to be ingested into the Security Lake Data Lake"
# }