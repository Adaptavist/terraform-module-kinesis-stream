output "kinesis_stream_arn" {
  value = aws_kinesis_stream.autoscaling_kinesis_stream.arn
}

output "kinesis_stream_name" {
  value = aws_kinesis_stream.autoscaling_kinesis_stream.name
}
