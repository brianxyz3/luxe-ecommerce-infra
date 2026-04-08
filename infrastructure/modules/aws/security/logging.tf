resource "aws_flow_log" "vpc_flow" {
  log_destination      = data.aws_ssm_parameter.log_bucket_arn.value
  log_destination_type = "s3"
  vpc_id               = var.vpc_id
  traffic_type         = "ALL"
  destination_options {
    file_format = "parquet"
    per_hour_partition = true
  }
}
