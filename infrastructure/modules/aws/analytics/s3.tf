resource "aws_s3_bucket" "target_bucket" {
  bucket = "${var.project_name}-data-lake-2026"
}