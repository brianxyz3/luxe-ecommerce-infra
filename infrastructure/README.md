# Luxe E-Commerce Infrastructure

## Overview

This Terraform configuration defines the AWS core infrastructure for the Luxe e-commerce project. It deploys a frontend website, backend ECS services, networking, security, and database resources using reusable module structure.

## Architecture

- `modules/aws/core-infra/frontend`
  - S3 website bucket for frontend assets
  - CloudFront distribution with origin access control
  - SSM parameter for CloudFront distribution ID

- `modules/aws/core-infra/backend`
  - ECS Fargate cluster and task definitions
  - Path-based routing via Application Load Balancer
  - AWS CloudWatch log group for ECS
  - Uses a placeholder `hello-world` image by default

- `modules/aws/core-infra/network`
  - VPC with public, private, and DB subnets
  - Internet gateway and route table
  - ALB and target groups for ECS services
  - VPC endpoint for DynamoDB
  - SSM parameters for VPC metadata

- `modules/aws/core-infra/security`
  - ECS, ALB, and RDS security groups
  - ECS task execution IAM role
  - centralized logging bucket and S3 bucket policies
  - (WAF is currently stubbed as empty string)

- `modules/aws/core-infra/database`
  - PostgreSQL RDS instance with encryption and rotation
  - DynamoDB table with TTL
  - SSM parameters for database metadata and secrets

## Current Behavior

- The configuration is written for AWS only.
- `cloud_provider` supports `aws` or `azure`, but only AWS modules are implemented in this branch.
- The default provider region is `eu-west-1`.
- The state backend is configured to use an S3 bucket in `eu-west-1`.
- ECS container image is intentionally set to a placeholder and uses `ignore_changes` on container definitions so a separate CI/CD pipeline can update the deployed image.

## Terraform Backend

The Terraform state is stored in an S3 backend:

- Bucket: `luxe-ecommerce-tf-state-bucket`
- Key: `environments/prod/terraform.tfstate`
- Region: `eu-west-1`
- `use_lockfile = true`
- `encrypt = true`

## Variables

Default values are defined in `vars.tf`:

- `cloud_provider`: `aws`
- `project_name`: `luxe-ecommerce`
- `analytics_project_name`: `luxe-analytics`
- `aws_region`: `eu-west-1`
- `backend_container_port`: `3000`
- `environment`: `prod`
- `backend_services`: a map of backend routes:
  - `gateway`: `/api/gateway/*`
  - `user`: `/api/users/*`
  - `cart`: `/api/cart/*`
  - `product`: `/api/products/*`
  - `order`: `/api/orders/*`


## Deployment

1. Ensure AWS credentials are configured for the target account.
2. From `infrastructure/` run:

```bash
terraform init
terraform plan
terraform apply
```

3. To destroy the infrastructure:

```bash
terraform destroy
```

## Notes

- The private subnets and NAT configuration include temporary testing behavior and should be reviewed before production use.
- The CloudFront WAF ARN is currently empty and `web_acl_id` is commented out in `frontend/cloudfront.tf`.
- The backend uses Fargate tasks with `assign_public_ip = true` for direct internet access; change for production.
