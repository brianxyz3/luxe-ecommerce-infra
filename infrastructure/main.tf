module "aws_frontend" {
  source = "./modules/aws/core-infra/frontend"
  count  = var.cloud_provider == "aws" ? 1 : 0

  project_name                     = var.project_name
  env                              = var.environment
  waf_arn                          = module.aws_security[0].cloudfront_waf_arn
  logs_bucket_regional_domain_name = module.aws_security[0].log_bucket_regional_name
  logs_bucket                      = module.aws_security[0].log_bucket
}

module "aws_backend" {
  source = "./modules/aws/core-infra/backend"
  count  = var.cloud_provider == "aws" ? 1 : 0

  project_name   = var.project_name
  container_port = var.backend_container_port
  env            = var.environment
  vpc_id         = module.aws_network[0].vpc_id
  subnet_ids     = module.aws_network[0].priv_subnet_ids
  ecs_sg_id      = module.aws_security[0].ecs_sg_id
  tg_arn         = module.aws_network[0].tg_arn
  exec_role      = module.aws_security[0].exec_role_arn
  ecs_services   = var.backend_services
  region         = var.aws_region

  depends_on = [module.aws_network]
}

module "aws_db" {
  source = "./modules/aws/core-infra/database"
  count  = var.cloud_provider == "aws" ? 1 : 0

  project_name = var.project_name
  subnet_ids   = module.aws_network[0].db_subnet_ids
  rds_sg_id    = module.aws_security[0].rds_sg_id
  region       = var.aws_region
  env          = var.environment
}

module "aws_network" {
  source = "./modules/aws/core-infra/network"
  count  = var.cloud_provider == "aws" ? 1 : 0

  project_name  = var.project_name
  env           = var.environment
  alb_sg_id     = module.aws_security[0].alb_sg_id
  region        = var.aws_region
  ecs_services  = var.backend_services
  logs_bucket   = module.aws_security[0].log_bucket
  dynamo_db_arn = module.aws_db[0].dynamo_db_arn
}

module "aws_security" {
  source = "./modules/aws/core-infra/security"

  project_name = var.project_name
  vpc_id       = module.aws_network[0].vpc_id
  region       = var.aws_region
  env          = var.environment
  # alb_arn      = module.aws_network[0].alb_arn
}

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
  # alb_arn      = module.aws_network[0].alb_arn
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
  priv_sub_az    = module.analytics_aws_network[0].priv_subnet_az
}