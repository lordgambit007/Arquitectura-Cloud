# --- Proyecto base ---
aws_region = "us-east-1"
project    = "t1-backend"

# --- Red / VPC ---
vpc_id = "vpc-0b575bf0e526b1133"

# Subnets públicas (para el NLB o API Gateway VPC Link)
public_subnets = [
  "subnet-09f0fd48cc0295f30",
  "subnet-0bab4fdd2881e3124"
]

# --- Imagen en ECR ---
backend_image = "983101357532.dkr.ecr.us-east-1.amazonaws.com/t1-backend:lambda"

# --- Aplicación ---
container_port = 8080

# --- Base de datos ---
use_rds     = true
db_username = "postgres"
db_password = "ChangeMe123!"
db_name     = "appdb"
