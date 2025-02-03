

module "avst_notify_slack" {
  source = "git::https://github.com/Adaptavist/terraform-module-aws-alarms-slack.git?ref=5cecd79d0ca4addd50f8a2563f125b88e65909a6" # <- version 2.2.11

  count = var.enable_slack_notification ? 1 : 0

  function_name        = "${var.stream_name}-alarm-${var.tags["Avst:BusinessUnit"]}-${var.tags["Avst:Stage:Name"]}"
  description          = "Lambda for cloudwatch alarms from Kinesis"
  namespace            = var.tags["Avst:BusinessUnit"]
  name                 = "aws-alarms-slack"
  stage                = var.tags["Avst:Stage:Name"]
  tags                 = var.tags
  slack_webhook_url    = var.slack_webhook_url
  display_service_name = "${var.stream_name}-${var.tags["Avst:Stage:Name"]} Alarm"
  aws_region           = var.region
}