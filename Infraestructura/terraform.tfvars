# === Identidad del proyecto ===
project = "tarea2-bff"

# === Red ===
# Pega tu VPC real (ver paso 2.1 abajo)
vpc_id = "vpc-0b575bf0e526b1133"

# Pega 2 subnets públicas de esa VPC (ver paso 2.2 abajo)
public_subnet_ids = ["default-for-az", "default-for-az"]

# === ECS (tu BFF) ===
# Nombre del cluster ECS (o ARN). Ver paso 2.3
ecs_cluster_name = "arn:aws:ecs:us-east-1:983101357532:cluster"

# Nombre del servicio ECS. Ver paso 2.3
ecs_service_name = " arn:aws:ecs:us-east-1:983101357532"

# ARN de la Task Definition del BFF (ya confirmado por ti)
ecs_task_definition_arn = "arn:aws:ecs:us-east-1:983101357532:task-definition/bff-task:1"

# Security Group de las tareas ECS (el que usan las ENIs del servicio). Ver paso 2.4
ecs_tasks_sg_id = "sg-0b026e8f17fd02b3d"
