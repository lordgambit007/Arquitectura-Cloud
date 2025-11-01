data "aws_ecs_cluster" "bff" {
  cluster_name = var.ecs_cluster_name
}

resource "aws_ecs_service" "bff" {
  name            = var.ecs_service_name
  cluster         = var.ecs_cluster_name
  launch_type     = "FARGATE"
  desired_count   = 2
  task_definition = var.ecs_task_definition_arn

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_tasks_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.bff_tg.arn
    container_name   = "bff"
    container_port   = 8081
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

}
