data "aws_caller_identity" "current" {}
data "aws_ssm_parameter" "log_bucket_arn" {
  name = "/${var.project_name}/${var.env}/security/log_bucket_arn"
}