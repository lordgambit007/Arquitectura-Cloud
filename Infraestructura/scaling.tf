# Escalado automático del servicio ECS BFF
resource "aws_appautoscaling_target" "ecs_bff" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_bff_cpu" {
  name               = "bff-ecs-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_bff.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_bff.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_bff.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 60
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Regla para reenviar todo el tráfico /* al target group
resource "aws_lb_listener_rule" "fwd_all" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bff_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
