data "aws_elb_service_account" "main" {}

data "aws_caller_identity" "current" {}

# data "aws_ssm_parameter" "jdbc_sg_id" {
#   name = "/${var.project_name}/${var.env}/security/jdbc_sg_id"
# }