############################################################
# IAM para Lambda (ejecutar y leer de SQS)
############################################################

# Rol que asume la Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name               = "email-lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

# Política de confianza para Lambda
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Permisos gestionados básicos para escribir logs en CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política para permitir a la Lambda consumir mensajes de SQS
data "aws_iam_policy_document" "lambda_sqs_doc" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [aws_sqs_queue.email_queue.arn]
  }
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name   = "email-lambda-sqs-policy"
  policy = data.aws_iam_policy_document.lambda_sqs_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}


############################################################
# (Opcional) IAM para API Gateway si integras directo a SNS
############################################################

# Rol que puede asumir API Gateway
resource "aws_iam_role" "apigw_role" {
  name               = "email-apigw-role"
  assume_role_policy = data.aws_iam_policy_document.apigw_trust.json
}

data "aws_iam_policy_document" "apigw_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

# Permiso para que API Gateway publique a SNS (si usas integración directa)
data "aws_iam_policy_document" "apigw_sns_doc" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.email_topic.arn]
  }
}

resource "aws_iam_policy" "apigw_sns_policy" {
  name   = "apigw-sns-publish"
  policy = data.aws_iam_policy_document.apigw_sns_doc.json
}

resource "aws_iam_role_policy_attachment" "apigw_sns_attach" {
  role       = aws_iam_role.apigw_role.name
  policy_arn = aws_iam_policy.apigw_sns_policy.arn
}
