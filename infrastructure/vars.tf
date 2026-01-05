variable "cloud_provider" {
  description = "Cloud provider to deploy to (aws or azure)"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be either 'aws' or 'azure'."
  }
}


variable "project_name" {
  type        = string
  default     = "luxe-ecommerce"
  description = "Project name for resource naming"
}


variable "backend_container_image" {
  type        = string
  default     = "luxe-ecommerce"
  description = "Docker image for the backend container"
}


variable "backend_container_port" {
  type        = number
  default     = 3000
  description = "Port the backend container listens on"
}


variable "environment" {
  type        = string
  default     = "prod"
  description = "Environment name"
}