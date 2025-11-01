############################
# Networking para Lambda/RDS
############################

# SG para la Lambda (solo salida a Internet/NAT, sin ingresos)
resource "aws_security_group" "lambda_sg" {
  name        = "${local.name}-lambda-sg"
  description = "Security group for Lambda to reach RDS"
  vpc_id      = var.vpc_id

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${local.name}-lambda-sg" }
}

# Subnets PRIVADAS (CIDR /20 válidos)
resource "aws_subnet" "private_a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.96.0/20" # <- corregido
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags                    = { Name = "${local.name}-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.112.0/20" # <- corregido
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags                    = { Name = "${local.name}-private-b" }
}

# EIP para el NAT Gateway (sintaxis moderna)
resource "aws_eip" "nat_eip" {
  domain = "vpc" # <- corregido
  tags   = { Name = "${local.name}-nat-eip" }
}

# NAT Gateway en una SUBNET PÚBLICA existente (ajusta si es otra)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = "subnet-003c9aa0308f04abe" # pública existente
  tags          = { Name = "${local.name}-nat" }
}

# Route table PRIVADA con salida por NAT
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "${local.name}-private-rt" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
