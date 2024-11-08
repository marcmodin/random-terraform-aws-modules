
variable "name" {
  type        = string
  description = "The prefix to apply to all resources."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
  default     = null
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources."
}

variable "configuration" {
  type = object({
    log_format               = optional(string, "$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}")
    log_destination          = optional(string)
    kms_key_id               = optional(string)
    max_aggregation_interval = optional(number, 600)
    traffic_type             = optional(string, "ALL")
    destination_options = optional(
      object({
        file_format                = optional(string, "plain-text")
        per_hour_partition         = optional(bool, false)
        hive_compatible_partitions = optional(bool, false)
    }), null)
  })
  description = <<EOT
Specifies the configuration settings for enabling and managing flow logs.

Attributes:
- log_format (string, optional): The fields to include in the flow log record. Defaults to "$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}".
- **log_destination** (string, optional): The target location for the flow logs, such as an S3 bucket ARN or CloudWatch Log Group ARN.
- **retention_in_days** (number, optional): The number of days to retain logs. Defaults to 7 if not specified.
- **kms_key_id** (string, optional): The ID of the KMS key used for encrypting the flow logs.
- **max_aggregation_interval** (number, optional): The maximum interval of time during which a flow is captured and aggregated into a flow log record. Valid values are 60 seconds (1 minute) or 600 seconds (10 minutes). Defaults to 600.
- **traffic_type** (string, optional): The type of traffic to capture. Acceptable values are `ALL`, `ACCEPT`, or `REJECT`. Defaults to `ALL`.
- **destination_options** (object, optional): Configuration for advanced destination options, including:
  - **file_format** (string, optional): Format of the log files. Defaults to `plain-text`.
  - **per_hour_partition** (bool, optional): If true, partitions logs by hour. Defaults to `false`.
  - **hive_compatible_partitions** (bool, optional): If true, creates partitions compatible with Hive. Defaults to `false`.

EOT

}