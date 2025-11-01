variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "t1-backend"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  description = "IDs de subnets privadas a usar; si es null, usamos las que creamos en lambda_network.tf"
  type        = list(string)
  default     = null
}

variable "backend_image" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "use_rds" {
  type    = bool
  default = true
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type    = string
  default = "ChangeMe123!"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

locals {
  name             = var.project
  cw_log_prefix    = "/ecs/${var.project}"
  external_db_host = ""
  db_host          = try(aws_db_instance.this[0].address, local.external_db_host)
}
