module "aws_network" {
  source = "./modules/aws/network"
  # providers = { aws = aws.aws }
  count = var.cloud_provider == "aws" ? 1 : 0

  project_name = var.project_name
  env          = var.environment
  region       = var.aws_region
  logs_bucket  = module.aws_security[0].log_bucket
}

module "aws_security" {
  source = "./modules/aws/security"
  # providers = { aws = aws.aws }
  count = var.cloud_provider == "aws" ? 1 : 0

  project_name = var.project_name
  vpc_id       = module.aws_network[0].vpc_id
  region       = var.aws_region
  env          = var.environment
}

module "aws_analytics" {
  source = "./modules/aws/analytics"
  # providers = { aws = aws.aws }
  count = var.cloud_provider == "aws" ? 1 : 0


  project_name = var.project_name
  env          = var.environment
  region       = var.aws_region
  subnet_ids   = module.aws_network[0].priv_subnet_ids
  vpc_id       = module.aws_network[0].vpc_id
  sec_grp_id   = module.aws_security[0].glue_jdbc_sg_id
  rds_db_az    = "${var.aws_region}a"
}