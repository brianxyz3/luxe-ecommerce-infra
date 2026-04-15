output "ecs_sg_id" {
  value = aws_security_group.ecs-sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "exec_role_arn" {
  value = aws_iam_role.ecs-exec-role.arn
}

output "cloudfront_waf_arn" {
  # value = aws_wafv2_web_acl.cloudfront-waf.arn
  value = ""
}

output "log_bucket" {
  value = aws_s3_bucket.infra_logs.bucket
}

output "log_bucket_regional_name" {
  value = aws_s3_bucket.infra_logs.bucket_regional_domain_name
}