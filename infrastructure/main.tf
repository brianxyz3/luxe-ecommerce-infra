module "analytics_aws_network" {
  source = "./modules/aws/analytics-infra/network"
  count  = var.cloud_provider == "aws" ? 1 : 0

  project_name = var.project_name
  env          = var.environment
  region       = var.aws_region
}

module "analytics_aws_security" {
  source = "./modules/aws/analytics-infra/security"
  count  = var.cloud_provider == "aws" ? 1 : 0

  project_name = var.project_name
  vpc_id       = module.analytics_aws_network[0].vpc_id
  region       = var.aws_region
  env          = var.environment
}

module "analytics_aws_analytics" {
  source = "./modules/aws/analytics-infra/analytics"
  count  = var.cloud_provider == "aws" ? 1 : 0


  project_name = var.project_name
  env          = var.environment
  region       = var.aws_region
  subnet_id    = module.analytics_aws_network[0].priv_subnet_id
  vpc_id       = module.analytics_aws_network[0].vpc_id
  sec_grp_id   = module.analytics_aws_security[0].glue_jdbc_sg_id
  priv_sub_az  = module.analytics_aws_network[0].priv_subnet_az
}