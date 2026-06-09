module "monitoring_aws_network" {
  source = "./modules/aws/monitoring/network"
  count  = var.cloud_provider == "aws" ? 1 : 0

  project_name = var.monitoring_project_name
  region       = var.aws_region
  env          = var.environment

  # depends_on = [module.aws_network]
}

module "monitoring_aws_compute" {
  source = "./modules/aws/monitoring/compute"
  count  = var.cloud_provider == "aws" ? 1 : 0

  project_name  = var.monitoring_project_name
  region        = var.aws_region
  env           = var.environment
  subnet_id     = module.monitoring_aws_network[0].subnet_id
  grafana_sg_id = module.monitoring_aws_security[0].grafana_sg_id
  prometheus_sg_id = module.monitoring_aws_security[0].prometheus_sg_id
  loki_sg_id = module.monitoring_aws_security[0].loki_sg_id

  depends_on = [module.monitoring_aws_security]
}

module "monitoring_aws_security" {
  source = "./modules/aws/monitoring/security"
  count  = var.cloud_provider == "aws" ? 1 : 0

  project_name = var.monitoring_project_name
  region       = var.aws_region
  env          = var.environment
  vpc_id       = module.monitoring_aws_network[0].vpc_id
  subnet_id    = module.monitoring_aws_network[0].subnet_id

  depends_on = [module.monitoring_aws_network]
}