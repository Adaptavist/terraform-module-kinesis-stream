# Input variable definitions
variable "stream_name" {
  type        = string
  description = "Stream Name"
}

variable "encryption_type" {
  type        = string
  description = "Encryption Key"
  default     = "KMS"
}

variable "kms_key_id" {
  type        = string
  description = "KMS Key"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags that should be applied to all resources"
}

variable "shard_count" {
  type        = number
  description = "Number of Shards"
}

variable "min_shard_count" {
  type        = number
  description = "Minimum Number of Shards greater than zero"
}

variable "stream_retention_period" {
  default     = 24
  type        = number
  description = "Stream Retention Period"
}

variable "kinesis_scaling_period_mins" {
  default     = 5
  type        = number
  description = "Scaling Period in minute"
}

variable "kinesis_scale_up_threshold" {
  default     = 0.75
  type        = number
  description = "Scale up threshold"
}


variable "kinesis_scale_up_evaluation_period" {
  default     = 5
  type        = number
  description = "Period after which the data for the alarm will be evaluated to scale up"
}

variable "kinesis_scale_up_datapoints_required" {
  default     = 5
  type        = number
  description = "Number of datapoints required in the evaluationPeriod to trigger the alarm to scale up"
}

variable "kinesis_scale_down_threshold" {
  default     = 0.25
  type        = number
  description = "Scale down threshold"
}

variable "kinesis_scale_down_evaluation_period" {
  default     = 60
  type        = number
  description = "Period after which the data for the alarm will be evaluated to scale down"
}

variable "kinesis_scale_down_datapoints_required" {
  default     = 57
  type        = number
  description = "Number of datapoints required in the evaluationPeriod to trigger the alarm to scale down"
}

variable "kinesis_scale_down_min_iter_age_mins" {
  default     = 30
  type        = number
  description = "To compare with streams max iterator age. If the streams max iterator age is above this, then the stream will not scale down"
}


variable "enable_slack_notification" {
  type        = bool
  default     = false
  description = "Enable Scale Notification"
}

variable "slack_web_hook" {
  type        = string
  description = "Web hook name"
}
