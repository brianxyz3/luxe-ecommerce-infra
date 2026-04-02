variable "project_name" {}
variable "env" {}
variable "region" {}
variable "logs_bucket" {}

variable "subnet_count" {
  type    = number
  default = 1
}