data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "slack_webhook" {
  name            = var.slack_web_hook
  with_decryption = true
}
