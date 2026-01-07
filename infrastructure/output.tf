output "s3_website" {
  value = module.aws_frontend[0].s3_website
}

output "cdn_domain_name" {
  value = module.aws_frontend[0].cdn_domain_name
}