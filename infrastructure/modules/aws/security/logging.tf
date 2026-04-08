resource "aws_s3_bucket" "infra_logs" {
  bucket        = "${var.project_name}-${var.env}-logs"
  force_destroy = false

  tags = {
    Name        = "${var.project_name}-logs-bucket"
    Environment = var.env
  }
}

resource "aws_ssm_parameter" "infra_logs" {
  name = "/${var.project_name}/${var.env}/security/log_bucket_arn"
  type = "String"
  value = aws_s3_bucket.infra_logs.arn
}

resource "aws_s3_bucket_lifecycle_configuration" "name" {
  bucket = aws_s3_bucket.infra_logs.id

  rule {
    id = "logs"

    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.infra_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_flow_log" "vpc_flow" {
  log_destination      = aws_s3_bucket.infra_logs.arn
  log_destination_type = "s3"
  vpc_id               = var.vpc_id
  traffic_type         = "ALL"
  destination_options {
    file_format        = "parquet"
    per_hour_partition = true
  }
}
