
module "kinesis_scaling" {
  source = "./modules/stream_scaling"

  stream_name                            = var.stream_name
  shard_count                            = var.shard_count
  min_shard_count                        = var.min_shard_count
  max_shard_scaling_factor               = var.max_shard_scaling_factor
  stream_retention_period                = var.stream_retention_period
  encryption_type                        = var.encryption_type
  kms_key_id                             = var.kms_key_id
  tags                                   = var.tags
  kinesis_period_mins                    = var.kinesis_scaling_period_mins
  kinesis_cooldown_mins                  = var.kinesis_cooldown_mins
  kinesis_scale_down_datapoints_required = var.kinesis_scale_down_datapoints_required
  kinesis_scale_down_evaluation_period   = var.kinesis_scale_down_evaluation_period
  kinesis_scale_down_min_iter_age_mins   = var.kinesis_scale_down_min_iter_age_mins
  kinesis_scale_down_threshold           = var.kinesis_scale_down_threshold
  kinesis_scale_up_datapoints_required   = var.kinesis_scale_up_datapoints_required
  kinesis_scale_up_evaluation_period     = var.kinesis_scale_up_evaluation_period
  kinesis_scale_up_threshold             = var.kinesis_scale_up_threshold
  enable_slack_notification              = var.enable_slack_notification
  account_id                             = data.aws_caller_identity.current.account_id
  region                                 = data.aws_region.current.name
  slack_webhook_url                      = var.slack_web_hook_url
}
