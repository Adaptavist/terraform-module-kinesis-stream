# Output variable definitions
output "kinesis_stream_arn" {
  value = var.enable_autoscaling ? module.kinesis_scaling.0.scale_kinesis_stream_arn : module.kinesis_no_scaling.0.kinesis_stream_arn
}