# VPC Flow Log S3 Bucket Policies

data "aws_iam_policy_document" "allow_s3_logging" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.infra_logs.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_s3_logging" {
  bucket = aws_s3_bucket.infra_logs.id
  policy = data.aws_iam_policy_document.allow_s3_logging.json
}

resource "aws_s3_bucket_policy" "allow_s3_logging" {
  bucket = aws_s3_bucket.infra_logs.id
  policy = data.aws_iam_policy_document.allow_s3_logging.json
}

resource "aws_s3_bucket_policy" "allow_flow_logs" {
  bucket = aws_s3_bucket.infra_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.infra_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control",
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          ArnLike = {
            "aws:SourceArn": [
              "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/fl-*"
            ]
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.infra_logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}