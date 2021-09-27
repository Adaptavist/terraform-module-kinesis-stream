variable "account_id" {
  type        = string
  description = "Account Id"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "stream_name" {
  type        = string
  description = "Stream Name"
}

variable "encryption_type" {
  type        = string
  description = "Encryption Type"
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
  description = "Minimum Number of Shards"
}

variable "stream_retention_period" {
  type        = number
  description = "Stream Retention Period"
}

variable "kinesis_period_mins" {
  type        = number
  description = "Scaling Period in minute"
}

variable "kinesis_scale_up_threshold" {
  type        = number
  description = "Scale up threshold"
}


variable "kinesis_scale_up_evaluation_period" {
  type        = number
  description = "Period after which the data for the alarm will be evaluated to scale up"
}

variable "kinesis_scale_up_datapoints_required" {
  type        = number
  description = "Number of datapoints required in the evaluationPeriod to trigger the alarm to scale up"
}

variable "kinesis_scale_down_threshold" {
  type        = number
  description = "Scale down threshold"
}

variable "kinesis_scale_down_evaluation_period" {
  type        = number
  description = "Period after which the data for the alarm will be evaluated to scale down"
}

variable "kinesis_scale_down_datapoints_required" {
  type        = number
  description = "Number of datapoints required in the evaluationPeriod to trigger the alarm to scale down"
}

variable "kinesis_scale_down_min_iter_age_mins" {
  type        = number
  description = "To compare with streams max iterator age. If the streams max iterator age is above this, then the stream will not scale down"
}
variable "enable_autoscaling" {
  type        = bool
  description = "Enable autoscaling"
}

variable "enable_slack_notification" {
  type        = bool
  description = "Enable Scale Notification"
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack Webhook URL"
}

