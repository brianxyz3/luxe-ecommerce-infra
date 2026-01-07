output "s3_website" {
  value = aws_s3_bucket.frontend.website_endpoint
}

output "cdn_domain_name" {
  value = aws_cloudfront_distribution.frontend-cdn.domain_name
}