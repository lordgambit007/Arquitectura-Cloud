output "alb_dns_name" {
  value       = aws_lb.bff_alb.dns_name
  description = "DNS público del ALB"
}
