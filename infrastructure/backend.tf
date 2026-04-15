terraform {
  backend "s3" {
    bucket       = "luxe-ecommerce-tf-state-bucket"
    key          = "environments/prod/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}