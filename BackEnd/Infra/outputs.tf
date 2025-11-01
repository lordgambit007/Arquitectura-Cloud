output "backend_invoke_url" {
  value = aws_api_gateway_stage.stage.invoke_url
}

output "backend_api_key" {
  value     = aws_api_gateway_api_key.lambda_key.value
  sensitive = true
}

output "rds_endpoint" {
  value = aws_db_instance.this[0].address
}
