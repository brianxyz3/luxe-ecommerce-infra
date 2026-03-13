variable "project_name" {}
variable "env" {}
variable "region" {}
variable "alb_sg_id" {}
variable "logs_bucket" {}

variable "subnet_count" {
  type = number
  default = 2
}

variable "ecs_services" {
  type = map(object({
    path = string
  }))
}