terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.aws_region
}

# ---------- VPC ----------
resource "aws_vpc" "bff_vpc" {
  cidr_block           = "10.71.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "bff_igw" {
  vpc_id = aws_vpc.bff_vpc.id
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.bff_vpc.id
  cidr_block              = "10.71.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.bff_vpc.id
  cidr_block              = "10.71.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"
}

resource "aws_route_table" "bff_rt" {
  vpc_id = aws_vpc.bff_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bff_igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.bff_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.bff_rt.id
}

# ---------- Security Groups ----------
resource "aws_security_group" "alb_sg" {
  name   = "bff-alb-sg"
  vpc_id = aws_vpc.bff_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "svc_sg" {
  name   = "bff-svc-sg"
  vpc_id = aws_vpc.bff_vpc.id

  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- ALB ----------
resource "aws_lb" "bff_alb" {
  name               = "bff-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "bff_tg" {
  name        = "bff-tg-ip" # target group nuevo/forzado a IP
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.bff_vpc.id
  target_type = "ip" # requerido por ECS Fargate (awsvpc)

  health_check {
    path                = "/health"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "bff_listener" {
  load_balancer_arn = aws_lb.bff_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bff_tg.arn
  }
}

# ---------- IAM ----------
data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bff_exec_role" {
  name               = "bff-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.bff_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "bff_task_role" {
  name               = "bff-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

data "aws_iam_policy_document" "sns_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [var.sns_topic_arn]
  }
}

resource "aws_iam_policy" "sns_policy" {
  name   = "bff-sns-publish"
  policy = data.aws_iam_policy_document.sns_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "sns_attach" {
  role       = aws_iam_role.bff_task_role.name
  policy_arn = aws_iam_policy.sns_policy.arn
}

# ---------- CloudWatch Logs ----------
resource "aws_cloudwatch_log_group" "bff_logs" {
  name              = "/ecs/bff"
  retention_in_days = 14
}

# ---------- ECS ----------
resource "aws_ecs_cluster" "bff_cluster" {
  name = "bff-cluster"
}

resource "aws_ecs_task_definition" "bff_task" {
  family                   = "bff-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.bff_exec_role.arn
  task_role_arn            = aws_iam_role.bff_task_role.arn

  container_definitions = jsonencode([{
    name      = "bff"
    image     = var.ecr_image
    essential = true
    portMappings = [
      { containerPort = 8081, hostPort = 8081, protocol = "tcp" }
    ]
    environment = [
      { name = "AWS_REGION", value = var.aws_region },
      { name = "SNS_TOPIC_ARN", value = var.sns_topic_arn }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.aws_region,
        awslogs-group         = "/ecs/bff",
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "bff_service" {
  name            = "bff-service"
  cluster         = aws_ecs_cluster.bff_cluster.id
  task_definition = aws_ecs_task_definition.bff_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.svc_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.bff_tg.arn
    container_name   = "bff"
    container_port   = 8081
  }

  depends_on = [
    aws_lb_listener.bff_listener,
    aws_cloudwatch_log_group.bff_logs
  ]
}

# ---------- API Gateway (REST) → ALB del BFF, con API Key obligatoria ----------

# Rol para que API Gateway publique logs en CloudWatch
resource "aws_iam_role" "apigw_cw_role" {
  name = "apigw-cloudwatch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "apigateway.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apigw_cw_attach" {
  role       = aws_iam_role.apigw_cw_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "apigw_account" {
  cloudwatch_role_arn = aws_iam_role.apigw_cw_role.arn
}

resource "aws_cloudwatch_log_group" "apigw_logs" {
  name              = "/aws/apigateway/bff"
  retention_in_days = 14
}

# Activa logging/métricas para todos los métodos del stage
resource "aws_api_gateway_method_settings" "bff_logs" {
  rest_api_id = aws_api_gateway_rest_api.bff_api.id
  stage_name  = aws_api_gateway_stage.bff_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO" # "ERROR" si quieres menos verboso
    data_trace_enabled = true   # request/response body (útil en pruebas)
  }

  depends_on = [aws_api_gateway_account.apigw_account]
}

resource "aws_api_gateway_api_key" "bff_key" {
  name    = "bff-api-key"
  enabled = true
}

resource "aws_api_gateway_rest_api" "bff_api" {
  name = "bff-rest-api"
}

resource "aws_api_gateway_resource" "bff_root_proxy" {
  rest_api_id = aws_api_gateway_rest_api.bff_api.id
  parent_id   = aws_api_gateway_rest_api.bff_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "bff_any" {
  rest_api_id      = aws_api_gateway_rest_api.bff_api.id
  resource_id      = aws_api_gateway_resource.bff_root_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "bff_http_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.bff_api.id
  resource_id             = aws_api_gateway_resource.bff_root_proxy.id
  http_method             = aws_api_gateway_method.bff_any.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.bff_alb.dns_name}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "bff_deploy" {
  rest_api_id = aws_api_gateway_rest_api.bff_api.id

  # Redeploy si cambia recurso / método / integración
  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_resource.bff_root_proxy.id,
      aws_api_gateway_method.bff_any.id,
      aws_api_gateway_integration.bff_http_proxy.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.bff_http_proxy]
}

resource "aws_api_gateway_stage" "bff_stage" {
  rest_api_id   = aws_api_gateway_rest_api.bff_api.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.bff_deploy.id
}

# Usage Plan SIN bloque throttle
resource "aws_api_gateway_usage_plan" "bff_plan" {
  name = "bff-usage-plan"

  # Asocia el stage del API a este usage plan
  api_stages {
    api_id = aws_api_gateway_rest_api.bff_api.id
    stage  = aws_api_gateway_stage.bff_stage.stage_name
  }

  # (Opcional) cuotas globales:
  # quota {
  #   limit  = 100000
  #   period = "MONTH"
  # }
}

resource "aws_api_gateway_usage_plan_key" "bff_upk" {
  key_id        = aws_api_gateway_api_key.bff_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.bff_plan.id
}

output "bff_apigw_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.bff_api.id}.execute-api.${var.aws_region}.amazonaws.com/prod"
}

output "bff_api_key_value" {
  value     = aws_api_gateway_api_key.bff_key.value
  sensitive = true
}