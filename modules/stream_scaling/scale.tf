locals {
  kinesis_scaling_function_name          = "${var.stream_name}-kinesis-scale-helper"
  kinesis_period_mins                    = var.kinesis_period_mins
  kinesis_period_secs                    = 60 * local.kinesis_period_mins
  kinesis_cooldown_period                = var.kinesis_cooldown_mins
  kinesis_scale_up_threshold             = var.kinesis_scale_up_threshold / 100 # Input parameter is in %
  kinesis_scale_up_evaluation_period     = var.kinesis_scale_up_evaluation_period
  kinesis_scale_up_datapoints_required   = var.kinesis_scale_up_datapoints_required
  kinesis_scale_down_threshold           = var.kinesis_scale_down_threshold / 100 # Input parameter is in %
  kinesis_scale_down_evaluation_period   = var.kinesis_scale_down_evaluation_period
  kinesis_scale_down_datapoints_required = var.kinesis_scale_down_datapoints_required
  kinesis_scale_down_min_iter_age_mins   = var.kinesis_scale_down_min_iter_age_mins
  kinesis_fatal_error_metric_name        = "FATAL_ERROR_KINESIS_SCALING"
  slack_notification_arn                 = var.enable_slack_notification ? module.avst_notify_slack.0.alarms_topic_arn : ""

  kinesis_consumer_lambda_arn        = "" # No consumer lambda function so it will be ignored
  kinesis_consumer_lambdas_per_shard = 1  # Note: Max is 10, you can max it out if a stream can't catch up. Defaulted to one as there is no lambda consumer

}

module "scaling_kinesis_lambda" {
  source                             = "Adaptavist/aws-lambda/module"
  version                            = "1.35.8"
  name                               = local.kinesis_scaling_function_name
  namespace                          = var.tags["Avst:BusinessUnit"]
  stage                              = var.tags["Avst:Stage:Name"]
  tags                               = var.tags
  lambda_code_dir                    = "${path.module}/lambda/kinesis_scaling"
  handler                            = "bootstrap"
  runtime                            = "provided.al2"
  timeout                            = 900
  memory_size                        = 512
  description                        = "Lambda function to scale up or down kinesis shards based on the load"
  function_name                      = local.kinesis_scaling_function_name
  enable_cloudwatch_logs             = true
  reserved_concurrent_executions     = 1
  aws_region                         = var.region
  disable_label_function_name_prefix = true

  environment_variables = {
    SCALE_PERIOD_MINS              = local.kinesis_period_mins
    SCALE_COOLDOWN_MINS            = local.kinesis_cooldown_period
    SCALE_UP_THRESHOLD             = local.kinesis_scale_up_threshold
    SCALE_UP_EVALUATION_PERIOD     = local.kinesis_scale_up_evaluation_period
    SCALE_UP_DATAPOINTS_REQUIRED   = local.kinesis_scale_up_datapoints_required
    SCALE_DOWN_THRESHOLD           = local.kinesis_scale_down_threshold
    SCALE_DOWN_EVALUATION_PERIOD   = local.kinesis_scale_down_evaluation_period
    SCALE_DOWN_DATAPOINTS_REQUIRED = local.kinesis_scale_down_datapoints_required
    SCALE_DOWN_MIN_ITER_AGE_MINS   = local.kinesis_scale_down_min_iter_age_mins
    SCALE_DOWN_MIN_COUNT           = var.min_shard_count
    SCALE_UP_MAX_FACTOR            = var.max_shard_scaling_factor
    ADDITIONAL_ALARM_ACTIONS       = "" # Placeholder for Future use, if additional actions (like slack notifications) needed
    PROCESSING_LAMBDA_ARN          = local.kinesis_consumer_lambda_arn
    PROCESSING_LAMBDAS_PER_SHARD   = local.kinesis_consumer_lambdas_per_shard
    THROTTLE_RETRY_MIN_SLEEP       = 1
    THROTTLE_RETRY_MAX_SLEEP       = 3
    THROTTLE_RETRY_COUNT           = 30
    DRY_RUN                        = "false"
  }
}

resource "aws_lambda_function_event_invoke_config" "kinesis_scaling_function_async_config" {
  function_name          = module.scaling_kinesis_lambda.lambda_name
  maximum_retry_attempts = 0 # We do not want any retries of the scaling function if it errors out, alarms will re-trigger it
}

resource "aws_cloudwatch_metric_alarm" "kinesis_scaling_fatal_errors" {
  alarm_name          = "${module.scaling_kinesis_lambda.lambda_name}-fatal-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = local.kinesis_fatal_error_metric_name
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "This metric monitors fatal errors in the kinesis scaling lambda"
  alarm_actions       = [local.slack_notification_arn]

  dimensions = {
    FunctionName = local.kinesis_scaling_function_name
  }
}
