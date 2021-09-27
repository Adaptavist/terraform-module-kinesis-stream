# Output variable definitions
output "kinesis_stream_arn" {
  value = module.kinesis_scaling.scale_kinesis_stream_arn
}