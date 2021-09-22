module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "4.17.0"

  count = var.slack_channel_name != "" ? 1 : 0

  sns_topic_name       = "${var.tags["Avst:Service"]}-slack-topic"
  lambda_function_name = "${var.tags["Avst:Service"]}-slack-notification"

  slack_webhook_url =  ""       //data.aws_ssm_parameter.slack_webhook.value
  slack_channel     = var.slack_channel_name
  slack_username    = "${var.tags["Avst:Service"]}-reporter"

  tags = var.tags
}