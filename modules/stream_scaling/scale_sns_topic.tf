locals {
  kinesis_scaling_sns_topic_name = "kinesis-scaling-topic-${var.stream_name}"
}

resource "aws_sns_topic" "kinesis_scaling_sns_topic" {
  name = local.kinesis_scaling_sns_topic_name
}

resource "aws_sns_topic_subscription" "kinesis_scaling_sns_topic_subscription" {
  topic_arn = aws_sns_topic.kinesis_scaling_sns_topic.arn
  protocol  = "lambda"
  endpoint  = module.scaling_kinesis.lambda_arn
}

resource "aws_lambda_permission" "kinesis_scaling_sns_topic_permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.scaling_kinesis.lambda_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.kinesis_scaling_sns_topic.arn
}
