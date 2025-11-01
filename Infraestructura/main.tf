# =========================
# Provider
# =========================
provider "aws" {
  region = "us-east-1"
}

# =========================
# SNS Topic
# =========================
resource "aws_sns_topic" "email_topic" {
  name = "email-topic"
}

# =========================
# SQS Queue
# =========================
resource "aws_sqs_queue" "email_queue" {
  name = "email-queue"
}

# Permitir que SNS publique en la cola SQS
resource "aws_sqs_queue_policy" "email_queue_policy" {
  queue_url = aws_sqs_queue.email_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.email_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.email_topic.arn
        }
      }
    }]
  })
}

# Suscripción SNS → SQS
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.email_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.email_queue.arn
}

# =========================
# Lambda (procesa mensajes de SQS)
# =========================
resource "aws_iam_role" "lambda_role" {
  name = "email-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Logs + acceso a SQS
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_lambda_function" "email_lambda" {
  function_name = "email-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.11"

  filename         = "${path.module}/lambda/email-lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/email-lambda.zip")

  timeout = 15
}

# Disparador SQS → Lambda
resource "aws_lambda_event_source_mapping" "lambda_trigger" {
  event_source_arn = aws_sqs_queue.email_queue.arn
  function_name    = aws_lambda_function.email_lambda.arn
}

# =========================
# API Gateway REST (v1) con API Key obligatoria
# Publica en SNS (no llama Lambda)
# =========================
# API
resource "aws_api_gateway_rest_api" "email_api" {
  name = "email-rest-api"
}

# /email
resource "aws_api_gateway_resource" "email_resource" {
  rest_api_id = aws_api_gateway_rest_api.email_api.id
  parent_id   = aws_api_gateway_rest_api.email_api.root_resource_id
  path_part   = "email"
}

# Método POST que exige API Key
resource "aws_api_gateway_method" "email_post" {
  rest_api_id      = aws_api_gateway_rest_api.email_api.id
  resource_id      = aws_api_gateway_resource.email_resource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

# Rol para que API Gateway pueda publicar en SNS
resource "aws_iam_role" "apigw_to_sns_role" {
  name = "apigw-to-sns-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Permiso mínimo: publicar SOLO en tu topic
resource "aws_iam_role_policy" "apigw_to_sns_policy" {
  name = "apigw-to-sns-policy"
  role = aws_iam_role.apigw_to_sns_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.email_topic.arn
    }]
  })
}

# Integración API GW → SNS (acción Publish)
resource "aws_api_gateway_integration" "email_integration" {
  rest_api_id = aws_api_gateway_rest_api.email_api.id
  resource_id = aws_api_gateway_resource.email_resource.id
  http_method = aws_api_gateway_method.email_post.http_method

  type                    = "AWS"
  integration_http_method = "POST"
  # Formato para acciones de servicio: sns:action/Publish
  uri         = "arn:aws:apigateway:${var.aws_region != null ? var.aws_region : "us-east-1"}:sns:action/Publish"
  credentials = aws_iam_role.apigw_to_sns_role.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  # Mapeo: toma el body JSON y lo manda como Message al Topic
  request_templates = {
    "application/json" = <<-EOT
      Action=Publish&TopicArn=$util.urlEncode('${aws_sns_topic.email_topic.arn}')&Message=$util.urlEncode($input.body)
    EOT
  }

  passthrough_behavior = "NEVER"
}

# Respuesta del método (200)
resource "aws_api_gateway_method_response" "email_200" {
  rest_api_id = aws_api_gateway_rest_api.email_api.id
  resource_id = aws_api_gateway_resource.email_resource.id
  http_method = aws_api_gateway_method.email_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# Respuesta de integración (devuelve 200 si SNS respondió OK)
resource "aws_api_gateway_integration_response" "email_integration_200" {
  rest_api_id = aws_api_gateway_rest_api.email_api.id
  resource_id = aws_api_gateway_resource.email_resource.id
  http_method = aws_api_gateway_method.email_post.http_method
  status_code = aws_api_gateway_method_response.email_200.status_code

  response_templates = {
    "application/json" = <<-EOT
      {
        "status": "queued",
        "via": "sns",
        "message": "OK"
      }
    EOT
  }
}

# Deployment + Stage
resource "aws_api_gateway_deployment" "email_deploy" {
  rest_api_id = aws_api_gateway_rest_api.email_api.id
  depends_on = [
    aws_api_gateway_integration.email_integration,
    aws_api_gateway_integration_response.email_integration_200
  ]
}

resource "aws_api_gateway_stage" "email_stage" {
  rest_api_id   = aws_api_gateway_rest_api.email_api.id
  deployment_id = aws_api_gateway_deployment.email_deploy.id
  stage_name    = "prod"
}

# API Key + Usage Plan (obligatoria)
resource "aws_api_gateway_api_key" "client_key" {
  name    = "email-client-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "plan" {
  name = "email-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.email_api.id
    stage  = aws_api_gateway_stage.email_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "attach_key_to_plan" {
  key_id        = aws_api_gateway_api_key.client_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.plan.id
}

# =========================
# Variables (región para el URI de integración)
# =========================
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Región AWS a usar en la integración de API Gateway con SNS"
}

# =========================
# Outputs
# =========================
output "invoke_url" {
  value       = "https://${aws_api_gateway_rest_api.email_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.email_stage.stage_name}/email"
  description = "Endpoint REST para publicar en SNS (requiere x-api-key)"
}

output "api_key_value" {
  value       = aws_api_gateway_api_key.client_key.value
  sensitive   = true
  description = "Valor para header x-api-key"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.email_topic.arn
  description = "Topic al que se publica desde API Gateway"
}
