variable "project_name" {}
variable "env" {}
variable "region" {}
variable "alb_sg_id" {}

variable "ecs_services" {
  type = map(object({
    path = string
  }))
}