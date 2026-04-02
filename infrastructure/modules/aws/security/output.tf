output "glue_jdbc_sg_id" {
  value = aws_security_group.jdbc_sg.id
}

output "log_bucket" {
  value = aws_s3_bucket.infra_logs.bucket
}

output "log_bucket_regional_name" {
  value = aws_s3_bucket.infra_logs.bucket_regional_domain_name
}