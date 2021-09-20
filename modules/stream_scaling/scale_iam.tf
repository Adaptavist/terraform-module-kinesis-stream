
locals {
  kinesis_scaling_lambda_policy_name = "${local.kinesis_scaling_function_name}-policy"
}

##################################
# IAM Policy for Stream Handler Lambda
##################################
data "aws_iam_policy_document" "kinesis_scaling_lambda_policy_document" {
  statement {
    sid       = "AllowCreateCloudWatchAlarms"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:PutMetricData",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:SetAlarmState",
      "cloudwatch:TagResource"
    ]
  }

  statement {
    sid       = "AllowLoggingToCloudWatch"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid       = "AllowReadFromKinesis"
    effect    = "Allow"
    resources = ["arn:aws:kinesis:${local.region}:${local.account_id}:stream/${aws_kinesis_stream.autoscaling_kinesis_stream.name}"]

    actions = [
      "kinesis:DescribeStreamSummary",
      "kinesis:AddTagsToStream",
      "kinesis:ListTagsForStream",
      "kinesis:UpdateShardCount",
    ]
  }

  statement {
    sid       = "AllowPublishToSNS"
    effect    = "Allow"
    resources = ["arn:aws:sns:${local.region}:${local.account_id}:${aws_sns_topic.kinesis_scaling_sns_topic.name}"]

    actions = [
      "sns:Publish",
    ]
  }

  statement {
    sid       = "AllowChangeFunctionConcurrencyForLambda"
    effect    = "Allow"
    resources = ["arn:aws:lambda:${local.region}:${local.account_id}:function:${module.scaling_kinesis_lambda.lambda_name}"]

    actions = [
      "lambda:PutFunctionConcurrency",
      "lambda:DeleteFunctionConcurrency"
    ]
  }
}

resource "aws_iam_policy" "kinesis_scaling_lambda_policy" {
  name        = local.kinesis_scaling_lambda_policy_name
  path        = "/"
  description = "Policy for Central Logging Kinesis Auto-Scaling Lambda"
  policy      = data.aws_iam_policy_document.kinesis_scaling_lambda_policy_document.json
  tags        = var.tags
}

##################################
# Attach Lambda Policy to Role
##################################
resource "aws_iam_role_policy_attachment" "attach_kinesis_scaling_lambda_policy" {
  role       = module.scaling_kinesis_lambda.lambda_role_name
  policy_arn = aws_iam_policy.kinesis_scaling_lambda_policy.arn
}
