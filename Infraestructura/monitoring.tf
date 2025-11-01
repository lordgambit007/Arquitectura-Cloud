resource "aws_cloudwatch_metric_alarm" "tg_5xx" {
  alarm_name          = "ALB-TG-5XX-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10

  dimensions = {
    LoadBalancer = aws_lb.bff_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.bff_tg.arn_suffix
  }

  alarm_description  = "Más de 10 respuestas 5XX del Target Group en 5 min"
  treat_missing_data = "notBreaching"
}
