

module "avst_notify_slack" {
  source  = "api.env0.com/7d93e902-0a96-4925-853c-5b221f4e4b1b/alarms-slack/aws"
  version = "2.3.10"

  count = var.enable_slack_notification ? 1 : 0

  function_name        = substr("${var.stream_name}-alarm-${var.tags["Avst:BusinessUnit"]}-${var.tags["Avst:Stage:Name"]}", 0, 64)
  description          = "Lambda for cloudwatch alarms from Kinesis"
  namespace            = var.tags["Avst:BusinessUnit"]
  name                 = "aws-alarms-slack"
  stage                = var.tags["Avst:Stage:Name"]
  tags                 = var.tags
  slack_webhook_url    = var.slack_webhook_url
  display_service_name = "${var.stream_name}-${var.tags["Avst:Stage:Name"]} Alarm"
  aws_region           = var.region
}