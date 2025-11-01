#########################################
# API Gateway REST con API Key obligatorio
#########################################

resource "aws_api_gateway_rest_api" "lambda_api" {
  name        = "${local.name}-rest"
  description = "REST API for ${local.name} (Lambda)"
}

# Recurso proxy: /{proxy+}
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "{proxy+}"
}

# Métodos ANY (root y proxy), con API Key obligatoria
resource "aws_api_gateway_method" "any_root" {
  rest_api_id      = aws_api_gateway_rest_api.lambda_api.id
  resource_id      = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "any_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.lambda_api.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

# Integraciones proxy a Lambda
# Para REST API, el URI debe ser el formato "lambda:path/.../invocations"
locals {
  lambda_invoke_uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.backend.arn}/invocations"
}

resource "aws_api_gateway_integration" "root_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method             = aws_api_gateway_method.any_root.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = local.lambda_invoke_uri
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.any_proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = local.lambda_invoke_uri
}

# Despliegue y stage
resource "aws_api_gateway_deployment" "dep" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id

  # Forzar redeploy cuando cambie algo (puede ser timestamp)
  triggers = {
    redeploy = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.root_integration,
    aws_api_gateway_integration.proxy_integration,
    aws_api_gateway_method.any_root,
    aws_api_gateway_method.any_proxy,
  ]
}


resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.dep.id
}


# Permiso para que API GW invoque la Lambda
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/*/*"
}

# API Key + Usage Plan
resource "aws_api_gateway_api_key" "lambda_key" {
  name    = "${local.name}-api-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "lambda_plan" {
  name = "${local.name}-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.lambda_api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }

  throttle_settings {
    rate_limit  = 50
    burst_limit = 100
  }
}

resource "aws_api_gateway_usage_plan_key" "bind" {
  key_id        = aws_api_gateway_api_key.lambda_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.lambda_plan.id
}
