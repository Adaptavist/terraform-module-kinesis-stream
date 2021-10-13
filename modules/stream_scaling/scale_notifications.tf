module "avst_notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "4.17.0"

  count = var.enable_slack_notification ? 1 : 0

  sns_topic_name       = "${var.stream_name}-slack-topic"
  lambda_function_name = "${var.stream_name}-slack-notification"

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = var.slack_channel_name
  slack_username    = "${var.stream_name}-reporter"

  tags = var.tags
}

