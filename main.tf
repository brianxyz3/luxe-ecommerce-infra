# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

module "aws_frontend" {
  source    = "./modules/aws/frontend"
  providers = { aws = aws.aws }
  count     = var.cloud_provider == "aws" ? 1 : 0

  project_name = var.project_name
  env          = var.environment
}

# module "aws_backend" {
#   source    = "./modules/aws/backend"
#   providers = { aws = aws.aws }
#   count     = var.cloud_provider == "aws" ? 1 : 0

#   project_name    = var.project_name
#   container_image = var.backend_container_image
#   container_port  = var.backend_container_port
#   env             = var.environment
#   vpc_id = module.aws_network[0].vpc_id
#   subnet_ids = module.aws_network[0].subnet_ids
#   ecs_sg_id = module.aws_security[0].ecs_sg_id
#   alb_arn = module.aws_network[0].vpc_arn
#   region          = "us-east-1"
# }

# module "aws_network" {
#   source = "./modules/aws/network"
#   providers = { aws = aws.aws }
#   count = var.cloud_provider == "aws" ? 1 : 0

#   project_name = var.project_name
#   env = var.environment
#   alb_sg_id = module.aws_security[0].alb_sg_id
#   region = "us-east-1"
# }

# module "aws_security" {
#   source = "./modules/aws/security"
#   providers = { aws = aws.aws }
#   count = var.cloud_provider == "aws" ? 1 : 0

#   project_name = var.project_name
#   vpc_id = module.aws_network[0].vpc_id
# }
