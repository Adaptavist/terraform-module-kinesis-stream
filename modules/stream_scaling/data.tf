
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "slack_webhook" {
  name            = "slack_webhook"
  with_decryption = true
}
