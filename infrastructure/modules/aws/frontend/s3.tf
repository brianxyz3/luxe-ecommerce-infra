resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend"

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.env
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudFrontObjectReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend-cdn.arn
          }
        }
      }
    ]
  })
}