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

# Important Note
Changes to the Kinesis stream shard count, as well as the scale up and scale down CloudWatch alarms are ignored by Terraform.
This is to allow the lambda to fully manage the shard count of the Kinesis stream which is also referenced in the alarms.

Only the initial values upon first applying the module will be used to configure the scaling alarms and kinesis stream.

In order to set new values for kinesis scaling (e.g. `min_shard_count`, `kinesis_scale_up_threshold`, `kinesis_scale_down_datapoints_required`, etc.), the scale up and scale down alarms must be tainted or deleted:
```
module.kinesis_scaling.aws_cloudwatch_metric_alarm.kinesis_scale_up
module.kinesis_scaling.aws_cloudwatch_metric_alarm.kinesis_scale_down
```
If `shard_count` needs to be be updated manually through TF, the above alarms and also the kinesis stream itself must be tainted or deleted:
```
module.kinesis_scaling.aws_kinesis_stream.autoscaling_kinesis_stream
```

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable\_slack\_notification | Enable Slack Notification | `bool` | `false` | no |
| encryption\_type | Encryption Type | `string` | `KMS` | no |
| kinesis\_cooldown\_mins | Cooling down Period in minutes | `number` | `10` | no |
| kinesis\_scale\_down\_datapoints\_required | Number of datapoints required in the evaluationPeriod to trigger the alarm to scale down | `number` | `285` | no |
| kinesis\_scale\_down\_evaluation\_period | Period after which the data for the alarm will be evaluated to scale down | `number` | `300` | no |
| kinesis\_scale\_down\_min\_iter\_age\_mins | To compare with streams max iterator age. If the streams max iterator age is above this, then the stream will not scale down | `number` | `30` | no |
| kinesis\_scale\_down\_threshold | Scale down threshold | `number` | `0.25` | no |
| kinesis\_scale\_up\_datapoints\_required | Number of datapoints required in the evaluationPeriod to trigger the alarm to scale up | `number` | `25` | no |
| kinesis\_scale\_up\_evaluation\_period | Period after which the data for the alarm will be evaluated to scale up | `number` | `25` | no |
| kinesis\_scale\_up\_threshold | Scale up threshold | `number` | `0.75` | no |
| kinesis\_scaling\_period\_mins | Scaling Period in minute | `number` | `5` | no |
| kms\_key\_id | KMS Key | `string` | n/a | yes |
| min\_shard\_count | Minimum Number of Shards greater than zero | `number` | `5` | yes |
| shard\_count | Number of Shards | `number` | `1` | no |
| slack\_web\_hook\_url | Slack web hook URL | `string` | n/a | yes |
| stream\_name | Stream Name | `string` | n/a | yes |
| stream\_retention\_period | Stream Retention Period | `number` | `24` | no |
| tags | Map of tags that should be applied to all resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| kinesis\_stream\_arn | Output variable definitions |
# Testing

To generate traffic on your streams you can use [Kinesis Data Generator](https://aws.amazon.com/blogs/big-data/test-your-streaming-data-solution-with-the-new-amazon-kinesis-data-generator/).


# Modifying / Recompiling the Lambda

Simply edit the `scale.go` file as needed and run `./build` to generate a main file suitable for Lambda deployment. Go 1.15.x is recommended.

# Reference code available at AWS-SAMPLE GIT HUB
(https://github.com/aws-samples/kinesis-auto-scaling/tree/main/terraform)