############################
# Lambda (imagen de ECR)
############################

resource "aws_iam_role" "lambda_exec" {
  name = "${local.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Permite logs en CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permite a la Lambda crear ENIs en tu VPC (para hablar con RDS)
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "backend" {
  function_name = "${local.name}-lambda"
  package_type  = "Image"
  image_uri     = var.backend_image
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      RUST_LOG                     = "info"
      SQLX_OFFLINE                 = "true"
      PORT                         = "8080"
      DATABASE_URL                 = "postgres://postgres:ChangeMe123!@t1-backend-db.cwvokqm8k8pc.us-east-1.rds.amazonaws.com:5432/appdb?sslmode=require&connect_timeout=10"
      AWS_LWA_READINESS_CHECK_PATH = "/api/health_check"
      AWS_LWA_ENABLE_COMPRESSION   = "true"
    }
  }

  vpc_config {
    subnet_ids = [
      "subnet-019357d1356ef2721",
      "subnet-003c9aa0308f04abe",
      "subnet-0405470a2304a39b7",
      "subnet-0f0bfeb8743f0b8a4"
    ]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.lambda_vpc_access
  ]
}
