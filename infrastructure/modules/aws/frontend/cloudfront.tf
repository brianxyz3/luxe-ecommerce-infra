resource "aws_cloudfront_distribution" "frontend-cdn" {
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "s3-${aws_s3_bucket.frontend.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.cdn-oac.id
  }


  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-${aws_s3_bucket.frontend.bucket}"
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # AWS Managed CachingOptimized

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  tags = {
    Name        = "${var.project_name}-cloudfront"
    Environment = var.env
  }
}

resource "aws_cloudfront_origin_access_control" "cdn-oac" {
  name                              = "${var.project_name}-oac"
  description                       = "Origin access control for S3 frontend bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_ssm_parameter" "name" {
  name  = "/${var.project_name}/${var.env}/cloudfront/cdn_id"
  type  = "String"
  value = aws_cloudfront_distribution.frontend-cdn.id
}