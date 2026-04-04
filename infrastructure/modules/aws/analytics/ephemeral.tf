data "aws_caller_identity" "current" {}

# data "aws_ssm_parameter" "rds_db_name" {
#   name = "/${var.project_name}/${var.env}/database/rds_db_name"
# }

# data "aws_ssm_parameter" "rds_db_az" {
#   name = "/${var.project_name}/${var.env}/database/rds_db_az"
# }

# data "aws_ssm_parameter" "rds_endpoint" {
#   name = "/${var.project_name}/${var.env}/database/rds_endpoint"
# }

# data "aws_ssm_parameter" "rds_secret_arn" {
#   name = "/${var.project_name}/${var.env}/database/rds_db_secret_arn"
# }

# data "aws_ssm_parameter" "dynamo_db_name" {
#   name = "/${var.project_name}/${var.env}/database/dynamo_db_name"
# }
