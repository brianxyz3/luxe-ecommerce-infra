variable "cloud_provider" {
  description = "Cloud provider to deploy to (aws or azure)"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be either 'aws' or 'azure'."
  }
}

variable "monitoring_project_name" {
  type        = string
  default     = "luxe-monitoring"
  description = "Project name for resource naming"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "Project region for provisioning resources"
}


variable "environment" {
  type        = string
  default     = "prod"
  description = "Environment name"
}