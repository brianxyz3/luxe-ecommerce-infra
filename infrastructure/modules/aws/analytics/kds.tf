resource "aws_kinesis_stream" "clicks_stream" {
  name             = "${var.project_name}-user-click-stream"
  shard_count      = 1
  retention_period = 24 # default is 24 hours


  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Environment = var.env
  }
}