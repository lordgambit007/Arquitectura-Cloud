# Subnet group ACTUAL (el que usa RDS hoy)
resource "aws_db_subnet_group" "this" {
  name        = "t1-backend-db-subnets"
  description = "Existing DB subnet group (in use)"
  subnet_ids = [
    "subnet-019357d1356ef2721",
    "subnet-003c9aa0308f04abe",
    "subnet-0405470a2304a39b7",
    "subnet-0f0bfeb8743f0b8a4",
  ]
  tags = { Name = "t1-backend-db-subnets" }

  lifecycle {
    ignore_changes  = [subnet_ids, name]
    prevent_destroy = true
  }
}


# Subnet group nuevo (no reemplaza directamente al viejo)
resource "aws_db_subnet_group" "private_v2" {
  name        = "t1-backend-db-subnets-v2"
  description = "Nuevo grupo de subredes privadas para RDS"
  subnet_ids = [
    "subnet-019357d1356ef2721",
    "subnet-003c9aa0308f04abe",
    "subnet-0405470a2304a39b7",
    "subnet-0f0bfeb8743f0b8a4"
  ]
  tags = {
    Name = "t1-backend-db-subnets-v2"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "db" {
  name   = "${local.name}-db-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "From Lambda"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.lambda_sg.id]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  count                  = var.use_rds ? 1 : 0
  identifier             = "${local.name}-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t4g.micro" # Free tier compatible
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}
