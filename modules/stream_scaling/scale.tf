locals {
  kinesis_scaling_function_name          = "${var.stream_name}-kinesis-scale-helper"
  kinesis_period_mins                    = var.kinesis_period_mins
  kinesis_period_secs                    = 60 * local.kinesis_period_mins
  kinesis_scale_up_threshold             = var.kinesis_scale_up_threshold
  kinesis_scale_up_evaluation_period     = var.kinesis_scale_up_evaluation_period / local.kinesis_period_mins # This value is used here and in stream.tf alarms
  kinesis_scale_up_datapoints_required   = var.kinesis_scale_up_datapoints_required / local.kinesis_period_mins
  kinesis_scale_down_threshold           = var.kinesis_scale_down_threshold
  kinesis_scale_down_evaluation_period   = var.kinesis_scale_down_evaluation_period / local.kinesis_period_mins
  kinesis_scale_down_datapoints_required = var.kinesis_scale_down_datapoints_required / local.kinesis_period_mins
  kinesis_scale_down_min_iter_age_mins   = var.kinesis_scale_down_min_iter_age_mins
  kinesis_fatal_error_metric_name        = "FATAL_ERROR_KINESIS_SCALING"



  kinesis_consumer_lambda_arn        = "arn:aws:lambda:${local.region}:${local.account_id}:function:${local.kinesis_scaling_function_name}"
  kinesis_consumer_lambdas_per_shard = 5 # Note: Max is 10, you can max it out if a stream can't catch up.

}

module "scaling_kinesis_lambda" {
  source                             = "Adaptavist/aws-lambda/module"
  version                            = "1.10.2"
  name                               = local.kinesis_scaling_function_name
  namespace                          = var.tags["Avst:BusinessUnit"]
  stage                              = var.tags["Avst:Stage:Name"]
  tags                               = var.tags
  lambda_code_dir                    = "${path.module}/lambda/kinesis_scaling"
  handler                            = "main"
  runtime                            = "go1.x"
  timeout                            = 900
  memory_size                        = 512
  description                        = "Lambda function to scale up or down kinesis shards based on the load"
  function_name                      = local.kinesis_scaling_function_name
  enable_cloudwatch_logs             = true
  reserved_concurrent_executions     = 1
  aws_region                         = local.region
  disable_label_function_name_prefix = true

  environment_variables = {
    SCALE_PERIOD_MINS              = local.kinesis_period_mins
    SCALE_UP_THRESHOLD             = local.kinesis_scale_up_threshold
    SCALE_UP_EVALUATION_PERIOD     = local.kinesis_scale_up_evaluation_period
    SCALE_UP_DATAPOINTS_REQUIRED   = local.kinesis_scale_up_datapoints_required
    SCALE_DOWN_THRESHOLD           = local.kinesis_scale_down_threshold
    SCALE_DOWN_EVALUATION_PERIOD   = local.kinesis_scale_down_evaluation_period
    SCALE_DOWN_DATAPOINTS_REQUIRED = local.kinesis_scale_down_datapoints_required
    SCALE_DOWN_MIN_ITER_AGE_MINS   = local.kinesis_scale_down_min_iter_age_mins
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
  alarm_name                = "${module.scaling_kinesis_lambda.lambda_name}-fatal-errors"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = local.kinesis_fatal_error_metric_name
  namespace                 = "AWS/Lambda"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "0"
  alarm_description         = "This metric monitors fatal errors in the kinesis scaling lambda"
  insufficient_data_actions = []

  dimensions = {
    FunctionName = local.kinesis_scaling_function_name
  }
}