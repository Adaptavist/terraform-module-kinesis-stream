
module "avst_notify_slack" {
  source  = "Adaptavist/aws-alarms-slack/module"
  version = "2.0.3"

  count = var.enable_slack_notification ? 1 : 0

  function_name        = "${var.tags["Avst:Service"]}-slack-notification"
  description          = "Function to create Slack notification"
  namespace            = var.tags["Avst:BusinessUnit"]
  stage                = var.tags["Avst:Stage:Name"]
  name                 = "function"
  tags                 = var.tags
  slack_webhook_url    = var.slack_webhook_url
  display_service_name = var.tags["Avst:Service"]
  aws_region           = var.region
}