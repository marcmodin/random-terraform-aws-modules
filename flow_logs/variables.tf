variable "name_prefix" {
  type        = string
  description = "The prefix to apply to all resources."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
  default     = null
}

variable "transit_gateway_id" {
  type        = string
  description = "The ID of the transit gateway"
  default     = null
}

variable "transit_gateway_attachment_id" {
  type        = string
  description = "The ID of the transit gateway attachment"
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet."
  default     = null
}

variable "eni_id" {
  type        = string
  description = "The ID of the network interface."
  default     = null
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources."
}

variable "log_format" {
  type        = string
  description = "The format of the flow logs. "
  default     = "$${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport}"
}

variable "max_aggregation_interval" {
  type        = number
  description = "The maximum interval of time during which a flow is captured and aggregated into a flow log record. Valid Values: 60 seconds (1 minute) or 600 seconds (10 minutes). When `transit_gateway_id` or `transit_gateway_attachment_id` is set, the valid values are 60 seconds"
  default     = 600
}

variable "configuration" {
  type = object({
    log_destination_type = string
    log_destination      = optional(string)
    retention_in_days    = optional(number, 7)
    kms_key_id           = optional(string)
    traffic_type         = optional(string, "ALL")
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
- **log_destination_type** (string, required): The type of destination for the flow logs. Must be one of `cloud-watch-logs` or `s3`.
- **log_destination** (string, optional): The target location for the flow logs, such as an S3 bucket ARN or CloudWatch Log Group ARN.
- **retention_in_days** (number, optional): The number of days to retain logs. Defaults to 7 if not specified.
- **kms_key_id** (string, optional): The ID of the KMS key used for encrypting the flow logs.
- **traffic_type** (string, optional): The type of traffic to capture. Acceptable values are `ALL`, `ACCEPT`, or `REJECT`. Defaults to `ALL`.
- **destination_options** (object, optional): Configuration for advanced destination options, including:
  - **file_format** (string, optional): Format of the log files. Defaults to `plain-text`.
  - **per_hour_partition** (bool, optional): If true, partitions logs by hour. Defaults to `false`.
  - **hive_compatible_partitions** (bool, optional): If true, creates partitions compatible with Hive. Defaults to `false`.

The `log_destination_type` must be set to either `cloud-watch-logs` or `s3` to pass validation.
EOT

  # create validation rule for log_destination_type, either cloud-watch-logs or s3
  validation {
    condition     = var.configuration.log_destination_type == "cloud-watch-logs" || var.configuration.log_destination_type == "s3"
    error_message = "log_destination_type must be either cloud-watch-logs or s3"
  }
}