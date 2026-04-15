variable "project_name" {}
variable "env" {}
variable "region" {}
variable "container_port" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "ecs_sg_id" {}
variable "tg_arn" {}
variable "exec_role" {}

variable "ecs_services" {
  type = map(object({
    path = string
  }))
}