resource "aws_glue_job" "dynamo_to_s3_etl" {
  name         = "dynamodb-to-s3-parquet"
  role_arn     = aws_iam_role.glue_service_role.arn
  max_retries  = 1
  timeout      = 720
  max_capacity = 0.0625
  glue_version = "5.0"
  job_mode     = "SCRIPT"

  execution_class = "STANDARD"

  command {
    name            = "pythonshell"
    script_location = "s3://${aws_s3_bucket.target_bucket.bucket}/jobs/etl_job.py" # Change this bucket name
    python_version  = "3.9"
  }

  notification_property {
    notify_delay_after = 3
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = "true"
    "--additional-python-modules"        = "boto3,pandas"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  tags = {
    "ManagedBy" = "AWS"
  }

}

resource "aws_glue_trigger" "daily_dynamo_export_trigger" {
  name = "daily-dynamodb-to-s3-trigger"
  type = "SCHEDULED"

  schedule = "cron(0 1 * * ? *)"

  start_on_creation = true

  actions {
    job_name = aws_glue_job.dynamo_to_s3_etl.name

    arguments = {
      "--continuous-log-logGroup" = aws_cloudwatch_log_group.dynamo_to_s3_log_group.name
      "--target_bucket"           = "s3://${aws_s3_bucket.target_bucket.bucket}/data/"
      "--dynamodb_table"      = "${data.aws_ssm_parameter.dynamo-db-name.value}"
    }
  }
}

resource "aws_cloudwatch_log_group" "dynamo_to_s3_log_group" {
  name              = "/aws-glue/jobs/dynamodb-s3"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "rds_to_s3_log_group" {
  name              = "/aws-glue/jobs/rds-s3"
  retention_in_days = 14
}

resource "aws_glue_job" "rds_to_s3_etl" {
  name            = "rds_to_s3_paraquet"
  role_arn        = aws_iam_role.glue_service_role.arn
  max_capacity    = 0.0625
  max_retries     = 1
  timeout         = 720
  glue_version    = "5.0"
  job_mode        = "SCRIPT"
  execution_class = "STANDARD"

  connections = [aws_glue_connection.rds_connection.name]

  command {
    name            = "pythonshell"
    python_version  = "3.9"
    script_location = "s3://${aws_s3_bucket.target_bucket.bucket}/jobs/etl_job.py"
  }


  notification_property {
    notify_delay_after = 3
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = "true"
    "--additional-python-modules"        = "boto3,pandas"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  tags = {
    "ManagedBy" = "AWS"
  }
}

resource "aws_glue_trigger" "daily_rds_export_trigger" {
  name              = "daily-rds-db-to-s3-trigger"
  type              = "SCHEDULED"
  schedule          = "cron(0 1 * * ? *)"
  start_on_creation = true

  actions {
    job_name = aws_glue_job.rds_to_s3_etl.name

    arguments = {
      "--continuous-log-logGroup" = aws_cloudwatch_log_group.rds_to_s3_log_group.name
      "--target_bucket"           = "s3://${aws_s3_bucket.target_bucket.bucket}/data/"
    }
  }
}

# resource "aws_s3_object" "glue_etl_script" {
#   bucket = aws_s3_bucket.glue_scripts.id
#   key    = "jobs/etl_job.py"
#   source = "jobs/etl_job.py"
# }