# Luxe Ecommerce Analytics Infrastructure

This repository contains the AWS analytics infrastructure for the Luxe ecommerce platform.

The `infrastructure/` folder is built with Terraform and provisions analytics-specific AWS resources, including a data lake, event streaming, ETL jobs, and private network connectivity for secure analytics pipelines.

## What this repo contains

- `infrastructure/main.tf` — root Terraform configuration that instantiates the AWS analytics modules
- `infrastructure/providers.tf` — AWS provider configuration (currently set to `eu-west-1`)
- `infrastructure/vars.tf` — Terraform variables and defaults
- `infrastructure/modules/aws/analytics-infra/` — reusable AWS analytics modules
- `infrastructure/etl_job.py` — Glue Python shell ETL script for DynamoDB and RDS exports
- `infrastructure/firehose_clickstream_transformer.py` — Lambda transformer invoked by Kinesis Firehose
- `infrastructure/terraform.tfstate` / `terraform.tfstate.backup` — local Terraform state files

## Architecture overview

The infrastructure is focused on analytics workloads, including:

- AWS VPC and private subnet for analytics resources
- VPC peering to an existing application VPC
- VPC Flow Logs exported to S3
- An S3 data lake bucket for analytics output
- Amazon Kinesis stream for clickstream ingestion
- Amazon Kinesis Data Firehose delivery stream with dynamic partitioning and Parquet conversion
- AWS Lambda function that transforms clickstream records before delivery to S3
- AWS Glue jobs for DynamoDB-to-S3 and RDS-to-S3 ETL
- AWS Glue crawlers and Glue Data Catalog metadata for analytics datasets
- IAM roles and policies for Glue, Firehose, Lambda, and S3 access

## Modules

### Network module

- Creates a VPC and private subnet in `eu-west-1`
- Configures a VPC peering connection to an existing app VPC
- Exposes the VPC peering ID as an SSM parameter
- Creates a private S3 VPC endpoint

### Security module

- Creates a JDBC security group for private database connectivity
- Enables VPC Flow Logs to an S3 logging bucket via an SSM-backed destination ARN

### Analytics module

- Creates an S3 bucket named `${var.project_name}-data-lake-2026`
- Creates a Kinesis stream for click event ingestion
- Creates a Firehose delivery stream that:
  - reads from Kinesis
  - writes partitioned Parquet files into S3
  - uses Lambda processing for record transformation
  - integrates with AWS Glue schema/catalog metadata
- Creates AWS Glue jobs, triggers, crawlers, and a Glue catalog database
- Defines Glue JDBC connections to RDS and permissions for DynamoDB access

## ETL scripts

- `infrastructure/etl_job.py` — this Glue Python shell job scans a DynamoDB table and writes JSON data to S3. It is also used for RDS exports.
- `infrastructure/firehose_clickstream_transformer.py` — Lambda function code used by Firehose to preprocess clickstream records before storage.

## Prerequisites

- AWS credentials configured locally (via `AWS_PROFILE`, environment variables, or default credential chain)
- Terraform installed
- Existing AWS resources referenced through AWS Systems Manager Parameter Store:
  - `/{project_name}/{env}/network/vpc/analyticsxcore_vpc_peer_id`
  - `/{project_name}/{env}/network/vpc/analyticsxcore_vpc_peer_cidr`
  - `/{project_name}/{env}/database/rds_db_name`
  - `/{project_name}/{env}/database/rds_endpoint`
  - `/{project_name}/{env}/database/rds_db_secret_arn`
  - `/{project_name}/{env}/database/dynamo_db_name`
  - `/{project_name}/{env}/security/jdbc_sg_id`
  - `/{project_name}/{env}/security/log_bucket_arn`

## Usage

From the `infrastructure/` directory:

```bash
terraform init
terraform plan -var="project_name=luxe-ecommerce" -var="environment=prod"
terraform apply -var="project_name=luxe-ecommerce" -var="environment=prod"
```

If you need to override defaults, use any of the variables defined in `infrastructure/vars.tf`:

- `cloud_provider` — default `aws`
- `project_name` — default `luxe-ecommerce`
- `analytics_project_name` — default `luxe-analytics`
- `aws_region` — default `eu-west-1`
- `backend_container_port` — default `3000`
- `environment` — default `prod`

> Note: `providers.tf` currently sets the AWS provider region to `eu-west-1`.

## Notes

- The current Terraform configuration is primarily targeted at AWS analytics workloads, not the full frontend/backend ecommerce stack.
- The local state files `terraform.tfstate` and `terraform.tfstate.backup` are present in this repo. For production use, migrate to a remote backend.
- The Glue job script currently uploads DynamoDB export output into S3 and reuses the same script for RDS exports.

## Summary

This repository provisions the AWS analytics layer for Luxe, including event ingestion, data lake storage, Glue ETL jobs, and metadata cataloging. It is designed to integrate with an existing ecommerce application VPC and securely process analytics data using managed AWS services.
