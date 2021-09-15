# Kinesis Data Streams Auto Scaling

A lightweight system to automatically scale Kinesis Data Streams up and down based on throughput.

![Kinesis_Auto_Scaling](https://user-images.githubusercontent.com/85569859/121233258-788f3980-c860-11eb-825b-c857ddd13299.png)

# Event Flow 
- Step 1: Metrics flow from the `Kinesis Data Stream(s)` into `CloudWatch Metrics` (Bytes/Sec, Records/Sec)
- Step 2: Two alarms, `Scale Up` and `Scale Down`, evaluate those metrics and decide when to scale
- Step 3: When a scaling alarm triggers it sends a message to the `Scaling SNS Topic`
- Step 4: The `Scaling Lambda` processes that SNS message and…
  - Scales the `Kinesis Data Stream` up or down using UpdateShardCount
    - Scale Up events double the number of shards in the stream
    - Scale Down events halve the number of shards in the stream
  - Updates the metric math on the `Scale Up` and `Scale Down` alarms to reflect the new shard count.



# Features

1. Designed for simplicity and a minimal service footprint. 
2. Proven. This system has been battle tested, scaling thousands of production streams without issue.
3. Suitable for scaling massive amounts of streams. Each additional stream requires only 2 CloudWatch alarms.
4. Operations friendly. Everything is viewable/editable/debuggable in the console, no need to drop into the CLI to see what's going on.
5. Takes into account both ingress metrics `Records Per Second` and `Bytes Per Second` when deciding to scale a stream up or down.
6. Can optionally take into account egress needs via `Max Iterator Age` so streams that are N minutes behind (configurable) do not scale down and lose much needed Lambda processing power (Lambdas per Shard) because their shard count was reduced due to a drop in incoming traffic. 
7. Already designed out the box to work within the 10 UpdateShardCount per rolling 24 hour limit. 
8. Emits a custom CloudWatch error metric if scaling fails, you can alarm off this for added peace of mind.
9. Can optionally adjust reserved concurrency for your Lambda consumers as it scales their streams up and down. 

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| stream\_name | Kinesis stream Name | `string` | null | yes |
| cloudwatch\_kms\_key\_arn | The ARN of the KMS Key to use when encrypting log data | `string` | `null` | no |
| cloudwatch\_retention\_in\_days | The number of days you want to retain log events in lambda's log group | `number` | `14` | no |
| description | A description of the lambda function. | `any` | n/a | yes |
| disable\_label\_function\_name\_prefix | Indicates if prefixing of the lambda function name should be disabled. Defaults to false | `bool` | `false` | no |
| enable\_cloudwatch\_logs | Enable cloudwatch logs | `bool` | `true` | no |
| enable\_tracing | Enable tracing of requests. If tracing is enabled, tracing mode needs to be specified. | `bool` | `false` | no |
| environment\_variables | Environment variables | `map(string)` | `{}` | no |
| external\_lambda\_hash | n/a | `string` | `""` | no |
| function\_name | A unique name for the lambda function. | `string` | n/a | yes |
| handler | The function entrypoint. | `string` | n/a | yes |
| include\_region | If set to true the current providers region will be appended to any global AWS resources such as IAM roles | `bool` | `false` | no |
| kms\_key\_arn | KMS key used for decryption | `string` | `""` | no |
| lambda\_code\_dir | A directory containing the code that needs to be packaged. | `string` | `"src"` | no |
| memory\_size | Amount of memory in MB your Lambda Function can use at runtime | `string` | `"128"` | no |
| name | n/a | `string` | `"function"` | no |
| namespace | n/a | `string` | n/a | yes |
| publish\_lambda | Whether to publish creation/change as new Lambda Function Version. | `bool` | `false` | no |
| reserved\_concurrent\_executions | The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. | `number` | `-1` | no |
| runtime | The runtime environment for the Lambda function. Valid Values: nodejs10.x \| nodejs12.x \| java8 \| java11 \| python2.7 \| python3.6 \| python3.7 \| python3.8 \| dotnetcore2.1 \| dotnetcore3.1 \| go1.x \| ruby2.5 \| ruby2.7 \| provided | `string` | n/a | yes |
| ssm\_parameter\_names | Names of SSM parameters that lambda will be able to access | `list(string)` | `[]` | no |
| stage | n/a | `string` | n/a | yes |
| tags | n/a | `map(string)` | n/a | yes |
| timeout | timeout | `any` | n/a | yes |
| tracing\_mode | Required if tracing is enabled. Possible values: PassThrough or Active. See https://www.terraform.io/docs/providers/aws/r/lambda_function.html#mode | `string` | `null` | no |
| vpc\_security\_group\_ids | Allows the function to access VPC (if both 'subnet\_ids' and 'security\_group\_ids' are empty then vpc\_config is considered to be empty or unset, see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html for details). | `list(string)` | `[]` | no |
| vpc\_subnet\_ids | Allows the function to access VPC subnets (if both 'subnet\_ids' and 'security\_group\_ids' are empty then vpc\_config is considered to be empty or unset, see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html for details). | `list(string)` | `[]` | no |
# Testing

To generate traffic on your streams you can use [Kinesis Data Generator](https://aws.amazon.com/blogs/big-data/test-your-streaming-data-solution-with-the-new-amazon-kinesis-data-generator/).


# Modifying / Recompiling the Lambda

Simply edit the `scale.go` file as needed and run `./build` to generate a main file suitable for Lambda deployment. Go 1.15.x is recommended.
