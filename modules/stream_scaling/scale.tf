# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  kinesis_scaling_function_name          = "kinesis-scaling-${var.stream_name}"  //TODO
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
  # Note: There must always be at least a 2 datapoint difference between the scale-up and scaled-down datapoints.
  # >>>     Scale-Up requires  5 out of  5 data points (consecutive)     ...   25/5 = _5_
  # >>>   Scale-Down requires 57 out of 60 data points (non-consecutive) ...  285/5 = 57 and 300/5 = 60, 60-57 = _3_
  # The 2 datapoint difference references 60-57 = _3_ (scale-down) vs _5_ (scale-up). The reasoning for this difference is that you should never
  # be able to trigger a scale down immediately after a scale up. Say your throughput spiked just enough to scale up, then went away. Having > 3
  # consecutive datapoints above the scale-up threshold to trigger a scale-up means it's impossible to get 57 of 60 datapoints until you wait 300
  # minutes and those scale-up data points age out of the scale-down window.
  # Ok now the really confusing part: The reason 1 datapoint difference isn't enough is because we have 2 alarms and they can operate on slightly
  # different time alignments, internally, for calculating their datapoints, despite always showing datapoints at the 5 minute marks (12:05, 12:10
  # etc) in the graph. So you add 1 extra datapoint of difference, for a total of 2, to guard against this potential misalignment between the scale
  # up and scale-down alarms. You can see this internal difference by going to the alarm and looking at its history for an entry like "Alarm updated
  # from OK to In alarm" and clicking the time "2020-06-23 12:47:09" link on the row. The "newState" section will show the datapoints and their times
  # > "stateReason": "Threshold Crossed: 5 out of the last 5 datapoints [0.9162957064310709 (23/06/20 12:42:00), 0.934598798751831 (23/06/20 12:37:00...
  # As you can see these datapoints are not aligned along the 5 minute display boundary (12:05, 12:10) but rather 12:37, 12:42.

  kinesis_consumer_lambda_name       = "$kinesis-consumer-lambda"
  kinesis_consumer_lambda_arn        = "arn:aws:lambda:${local.region}:${local.account_id}:function:${local.kinesis_scaling_function_name}"
  kinesis_consumer_lambdas_per_shard = 5 # Note: Max is 10, you can max it out if a stream can't catch up.
  # Remove the kinesis_consumer_lambda ignore block for reserved_concurrent_executions if you change
  # this value or it won't apply when you deploy.
}

module "scaling_kinesis" {
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
  function_name          = module.scaling_kinesis.lambda_name
  maximum_retry_attempts = 0 # We do not want any retries of the scaling function if it errors out, alarms will re-trigger it
}

resource "aws_cloudwatch_metric_alarm" "kinesis_scaling_fatal_errors" {
  alarm_name                = "${module.scaling_kinesis.lambda_name}-fatal-errors"
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
