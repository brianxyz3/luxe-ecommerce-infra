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
  description = "Project name for resource naming and parameter fetching/storing"
}

variable "analytics_project_name" {
  type        = string
  default     = "luxe-analytics"
  description = "Project name for resource naming"
}

variable "analytics_project_name" {
  type        = string
  default     = "luxe-analytics"
  description = "Project name for analytics parameter fetching"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "Project region for provisioning resources"
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

variable "backend_services" {
  type = map(object({
    path = string
  }))
  default = {
    gateway = { path = "/api/gateway/*" },
    user    = { path = "/api/users/*" },
    cart    = { path = "/api/cart/*" },
    product = { path = "/api/products/*" },
    order   = { path = "/api/orders/*" },
    # payment      = { path = "/api/payments/*" },
    # inventory    = { path = "/api/inventory/*" },
    # notification = { path = "/api/notifications/*" },
  }
}
