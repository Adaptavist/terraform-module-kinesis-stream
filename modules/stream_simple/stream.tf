################################
# Kinesis Data Stream
################################
resource "aws_kinesis_stream" "kinesis_stream" {
  name             = var.stream_name
  shard_count      = var.shard_count
  retention_period = var.stream_retention_period
  encryption_type  = var.encryption_type
  kms_key_id       = var.kms_key_id
  tags             = var.tags

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