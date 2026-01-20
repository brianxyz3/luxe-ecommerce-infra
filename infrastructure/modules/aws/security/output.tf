output "ecs_sg_id" {
  value = aws_security_group.ecs-sg.id
}

output "exec_role_arn" {
  value = aws_iam_role.ecs-exec-role.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
}

output "cloudfront_waf_arn" {
  value = aws_wafv2_web_acl.cloudfront-waf.arn
}