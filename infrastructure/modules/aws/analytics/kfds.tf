resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "kinesis-firehose-clickstream-s3-delivery"
  destination = "extended_s3"
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.clicks_stream.arn
    role_arn = aws_iam_role.firehose_role.arn
  }
  

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.target_bucket.arn

    buffering_interval = 60
    buffering_size = 5

    prefix = "clicks/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

    dynamic_partitioning_configuration {
      enabled = "true"
    }

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_database.clickstream_db.name
        table_name    = aws_glue_catalog_table.clickstream_table.name
        role_arn      = aws_iam_role.firehose_role.arn
      }
    }
    

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
      }
    }

    cloudwatch_logging_options {
      enabled = true
    }
  }

}

resource "aws_lambda_function" "lambda_processor" {
  filename      = "lambda.zip"
  function_name = "firehose_clickstream_transformer"
  role          = aws_iam_role.lambda_role.arn
  handler       = "firehose_clickstream_transformer.lambda_handler"
  runtime       = "python3.11"
}

resource "aws_lambda_permission" "allow_firehose_invoke" {
  statement_id  = "AllowExecutionFromKinesisFirehose"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_processor.function_name
  principal     = "firehose.amazonaws.com"
  source_arn    = aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
}