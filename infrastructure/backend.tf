terraform {
  backend "s3" {
    bucket         = "luxe-ecommerce-tf-state-bucket"
    key            = "environments/prod/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}