/*module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "4.17.0"

  count                = var.slack_channel_name != "" ? 1 : 0
  sns_topic_name       = "${var.tags["Avst:Service"]}-slack-topic"
  lambda_function_name = "${var.tags["Avst:Service"]}-slack-notification"
  slack_webhook_url    = data.aws_ssm_parameter.slack_webhook.value
  slack_channel        = var.slack_channel_name
  slack_username       = "${var.tags["Avst:Service"]}-reporter"
  tags                 = var.tags
}*/


module "avst_notify_slack" {
  source  = "Adaptavist/aws-alarms-slack/module"
  version = "2.0.3"

  //count = var.slack_channel_name != "" ? 1 : 0

  //sns_topic_name       = "${var.tags["Avst:Service"]}-slack-topic"
  function_name     = "${var.tags["Avst:Service"]}-slack-notification"
  description       = "Function to create Slack notification"
  namespace         = var.tags["Avst:BusinessUnit"]
  stage             = var.tags["Avst:Stage:Name"]
  name              = "function"
  tags              = var.tags
  slack_webhook_url = data.aws_ssm_parameter.slack_webhook.value
  //slack_channel        = var.slack_channel_name
  display_service_name = var.tags["Avst:Service"]
  aws_region           = local.region
}