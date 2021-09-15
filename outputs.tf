# Output variable definitions
output "kinesis_stream_arn" {
  value = module.kinesis_scaling.kinesis_stream_arn
}