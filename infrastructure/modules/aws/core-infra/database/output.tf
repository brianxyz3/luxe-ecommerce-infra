output "dynamo_db_arn" {
  value = aws_dynamodb_table.dynamo_db.arn
}

output "dynamo_db_name" {
  value = aws_dynamodb_table.dynamo_db.name
}

output "rds_db_az" {
  value = aws_db_instance.rds_db.availability_zone
}

output "rds_endpoint" {
  value = aws_db_instance.rds_db.endpoint
}

output "rds_db_name" {
  value = aws_db_instance.rds_db.db_name
}