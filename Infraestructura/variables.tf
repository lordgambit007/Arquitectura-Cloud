variable "project" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" {
  type = list(string)
}
variable "ecs_cluster_name" { type = string }
variable "ecs_service_name" { type = string }

variable "ecs_task_definition_arn" {
  description = "ARN de la Task Definition del BFF ya existente"
  type        = string
}

variable "ecs_tasks_sg_id" {
  description = "Security Group ID que usan las tareas ECS (BFF)"
  type        = string
}
