resource "aws_glue_catalog_database" "glue_db" {
  name        = "${var.project_name}_glue_db"
  description = "Glue catalog database for ${var.project_name} project"

  create_table_default_permission {
    permissions = ["SELECT"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_glue_crawler" "dynamo_s3_crawler" {
  database_name = aws_glue_catalog_database.glue_db.name
  name          = "dynamo_data_s3_crawler"
  role          = aws_iam_role.glue_service_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.target_bucket.bucket}/dynamodb/"
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DELETE_FROM_DATABASE"
  }
}

resource "aws_glue_trigger" "dynamo_db_crawler_trigger" {
  name = "start-dynamo-s3-crawler-after-job-success"
  type = "CONDITIONAL"

  actions {
    crawler_name = aws_glue_crawler.dynamo_s3_crawler.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.dynamo_to_s3_etl.name
      state    = "SUCCEEDED"
    }
  }
}

resource "aws_glue_connection" "rds_connection" {
  name = "rds-connection"

  connection_type = "JDBC"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://${data.aws_ssm_parameter.rds_endpoint.value}/${data.aws_ssm_parameter.rds_db_name.value}"
    USERNAME            = "luxeadmin"
    PASSWORD = data.aws_ssm_parameter.rds_secret_arn.value
  }

  physical_connection_requirements {
    subnet_id              = var.subnet_id
    security_group_id_list = [var.sec_grp_id]
    availability_zone      = var.priv_sub_az
  }

}
# JDBC_CONNECTION_URL      = "jdbc:postgresql://${data.aws_ssm_parameter.rds-endpoint.value}/${data.aws_ssm_parameter.rds-db-name}"

resource "aws_glue_crawler" "rds_s3_db_crawler" {
  database_name = aws_glue_catalog_database.glue_db.name
  name          = "rds_db_crawler"
  role          = aws_iam_role.glue_service_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.target_bucket.bucket}/rds/"
  }

  # recrawl_policy {
  #   recrawl_behavior = "CRAWL_EVENT_MODE"
  # }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }
}

resource "aws_glue_trigger" "rds_db_crawler_trigger" {
  name = "start-rds-s3-crawler-after-job-success"
  type = "CONDITIONAL"

  actions {
    crawler_name = aws_glue_crawler.rds_s3_db_crawler.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.rds_to_s3_etl.name
      state    = "SUCCEEDED"
    }
  }
}

resource "aws_glue_catalog_database" "clickstream_db" {
  name = "clickstream_db"
}

resource "aws_glue_catalog_table" "clickstream_table" {
  name          = "clickstream_data"
  database_name = aws_glue_catalog_database.clickstream_db.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "parquet"
  }

  partition_keys {
    name = "year"
    type = "string"
  }

  partition_keys {
    name = "month"
    type = "string"
  }

  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.target_bucket.bucket}/clicks/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

    }

    # Defined columns exactly as they come out of the Lambda
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "timestamp"
      type = "timestamp"
    }
    columns {
      name = "value"
      type = "double"
    }
  }

}