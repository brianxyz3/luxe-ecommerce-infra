resource "aws_dynamodb_table" "dynamo_db" {
  name = "${var.project_name}-dynamo-db"
  billing_mode = "PROVISIONED"
  read_capacity = 5
  write_capacity = 5
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled = true
  }
}