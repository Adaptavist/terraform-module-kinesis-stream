
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

variable "stream_retention_period" {
  type        = number
  description = "Stream Retention Period"
}

variable "enable_slack_notification" {
  type        = bool
  description = "Enable Scale Notification"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack Webhook URL"
}

