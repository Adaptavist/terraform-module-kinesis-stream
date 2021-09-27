################################
# Kinesis Data Stream
################################
resource "aws_kinesis_stream" "autoscaling_kinesis_stream" {
  name             = var.stream_name
  shard_count      = var.shard_count
  retention_period = var.stream_retention_period
  encryption_type  = var.encryption_type
  kms_key_id       = var.kms_key_id
  tags             = var.tags

  shard_level_metrics = [
    "IncomingBytes", "IncomingRecords",
  ]

  lifecycle {
    ignore_changes = [
      shard_count, # Kinesis autoscaling will change the shard count outside of terraform
    ]
  }
}

resource "aws_cloudwatch_metric_alarm" "kinesis-write-throughput-exceeded" {
  alarm_name          = "${var.stream_name}-write-throughput"
  alarm_description   = "Indicates that the kinesis stream write throughput has been exceeded"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  threshold           = 10
  metric_name         = "WriteProvisionedThroughputExceeded"
  namespace           = "AWS/Kinesis"
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = compact(module.avst_notify_slack.*.alarms_topic_arn)
  ok_actions          = compact(module.avst_notify_slack.*.alarms_topic_arn)
  dimensions = {
    StreamName = var.stream_name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "kinesis-read-throughput-exceeded" {
  alarm_name          = "${var.stream_name}-read-throughput"
  alarm_description   = "Indicates that the kinesis stream provisioned read throughput has been exceeded"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  threshold           = 10
  metric_name         = "ReadProvisionedThroughputExceeded"
  namespace           = "AWS/Kinesis"
  statistic           = "Average"
  treat_missing_data  = "notBreaching"
  alarm_actions       = compact(module.avst_notify_slack.*.alarms_topic_arn)
  ok_actions          = compact(module.avst_notify_slack.*.alarms_topic_arn)
  dimensions = {
    StreamName = var.stream_name
  }
  tags = var.tags
}


######################################################
# Kinesis Data Stream Scaling Alarms
######################################################
resource "aws_cloudwatch_metric_alarm" "kinesis_scale_up" {
  alarm_name                = "${var.stream_name}-scale-up"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = local.kinesis_scale_up_evaluation_period   # Defined in scale.tf
  datapoints_to_alarm       = local.kinesis_scale_up_datapoints_required # Defined in scale.tf
  threshold                 = local.kinesis_scale_up_threshold           # Defined in scale.tf
  alarm_description         = "Stream throughput has gone above the scale up threshold"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.kinesis_scaling_sns_topic.arn,local.slack_notification_arn]
  tags                      = var.tags

  metric_query {
    id         = "s1"
    label      = "ShardCount"
    expression = var.shard_count
  }

  metric_query {
    id    = "m1"
    label = "IncomingBytes"
    metric {
      metric_name = "IncomingBytes"
      namespace   = "AWS/Kinesis"
      period      = local.kinesis_period_secs
      stat        = "Sum"
      dimensions = {
        StreamName = var.stream_name
      }
    }
  }

  metric_query {
    id    = "m2"
    label = "IncomingRecords"
    metric {
      metric_name = "IncomingRecords"
      namespace   = "AWS/Kinesis"
      period      = local.kinesis_period_secs
      stat        = "Sum"
      dimensions = {
        StreamName = var.stream_name
      }
    }
  }

  metric_query {
    id         = "e1"
    label      = "FillMissingDataPointsWithZeroForIncomingBytes"
    expression = "FILL(m1,0)"
  }

  metric_query {
    id         = "e2"
    label      = "FillMissingDataPointsWithZeroForIncomingRecords"
    expression = "FILL(m2,0)"
  }

  metric_query {
    id         = "e3"
    label      = "IncomingBytesUsageFactor"
    expression = "e1/(1024*1024*60*${local.kinesis_period_mins}*s1)"
  }

  metric_query {
    id         = "e4"
    label      = "IncomingRecordsUsageFactor"
    expression = "e2/(1000*60*${local.kinesis_period_mins}*s1)"
  }

  metric_query {
    id          = "e5"
    label       = "MaxIncomingUsageFactor"
    expression  = "MAX([e3,e4])" # Take the highest usage factor between bytes/sec and records/sec
    return_data = true
  }

  lifecycle {
    ignore_changes = [
      tags["LastScaledTimestamp"] # A tag that is updated every time Kinesis autoscales the stream
    ]
  }

  depends_on = [
    module.scaling_kinesis_lambda # The lambda function needs to be updated before the alarms. A scenario where
    # this matters is changing the scaling thresholds which are baked into the scaling
    # lambda environment variables. If the alarms are updated first it could trigger
    # the scaling lambda before terraform gives the lambda the new thresholds, resulting
    # in these scaling alarms being rebuilt by the alarm using the old thresholds.
  ]
}

resource "aws_cloudwatch_metric_alarm" "kinesis_scale_down" {
  alarm_name                = "${var.stream_name}-scale-down"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = local.kinesis_scale_down_evaluation_period                                       # Defined in scale.tf
  datapoints_to_alarm       = local.kinesis_scale_down_datapoints_required                                     # Defined in scale.tf
  threshold                 = var.shard_count == var.min_shard_count ? -1 : local.kinesis_scale_down_threshold # Defined in scale.tf
  alarm_description         = "Stream throughput has gone below the scale down threshold"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.kinesis_scaling_sns_topic.arn,local.slack_notification_arn]
  tags                      = var.tags

  metric_query {
    id         = "s1"
    label      = "ShardCount"
    expression = var.shard_count
  }

  metric_query {
    id         = "s2"
    label      = "IteratorAgeMinutesToBlockScaledowns"
    expression = local.kinesis_scale_down_min_iter_age_mins
  }

  metric_query {
    id    = "m1"
    label = "IncomingBytes"
    metric {
      metric_name = "IncomingBytes"
      namespace   = "AWS/Kinesis"
      period      = local.kinesis_period_secs
      stat        = "Sum"
      dimensions = {
        StreamName = var.stream_name
      }
    }
  }

  metric_query {
    id    = "m2"
    label = "IncomingRecords"
    metric {
      metric_name = "IncomingRecords"
      namespace   = "AWS/Kinesis"
      period      = local.kinesis_period_secs
      stat        = "Sum"
      dimensions = {
        StreamName = var.stream_name
      }
    }
  }

  metric_query {
    id    = "m3"
    label = "GetRecords.IteratorAgeMilliseconds"
    metric {
      metric_name = "GetRecords.IteratorAgeMilliseconds"
      namespace   = "AWS/Kinesis"
      period      = local.kinesis_period_secs
      stat        = "Maximum"
      dimensions = {
        StreamName = var.stream_name
      }
    }
  }

  metric_query {
    id         = "e1"
    label      = "FillMissingDataPointsWithZeroForIncomingBytes"
    expression = "FILL(m1,0)"
  }

  metric_query {
    id         = "e2"
    label      = "FillMissingDataPointsWithZeroForIncomingRecords"
    expression = "FILL(m2,0)"
  }

  metric_query {
    id         = "e3"
    label      = "IncomingBytesUsageFactor"
    expression = "e1/(1024*1024*60*${local.kinesis_period_mins}*s1)"
  }

  metric_query {
    id         = "e4"
    label      = "IncomingRecordsUsageFactor"
    expression = "e2/(1000*60*${local.kinesis_period_mins}*s1)"
  }

  metric_query {
    id         = "e5"
    label      = "IteratorAgeAdjustedFactor"
    expression = "(FILL(m3,0)/1000/60)*(${local.kinesis_scale_down_threshold}/s2)" # We want to block scaledowns when IterAge is > 60 mins, multiply IterAge so 60 mins = <alarmThreshold>
  }

  metric_query {
    id          = "e6"
    label       = "MaxIncomingUsageFactor"
    expression  = "MAX([e3,e4,e5])" # Take the highest usage factor between bytes/sec, records/sec, and adjusted iterator age
    return_data = true
  }

  lifecycle {
    ignore_changes = [
      tags["LastScaledTimestamp"] # A tag that is updated every time Kinesis autoscales the stream
    ]
  }

  depends_on = [
    module.scaling_kinesis_lambda # The lambda function needs to be updated before the alarms. A scenario where
    # this matters is changing the scaling thresholds which are baked into the scaling
    # lambda environment variables. If the alarms are updated first it could trigger
    # the scaling lambda before terraform gives the lambda the new thresholds, resulting
    # in these scaling alarms being rebuilt by the alarm using the old thresholds.
  ]
}
