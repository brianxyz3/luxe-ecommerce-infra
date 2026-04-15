resource "aws_dynamodb_table" "dynamo_db" {
  name           = "${var.project_name}-dynamo-db"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }
}

resource "aws_ssm_parameter" "dynamo_db_name" {
  name  = "/${var.project_name}/${var.env}/database/dynamo_db_name"
  type  = "String"
  value = aws_db_instance.rds_db.db_name
}