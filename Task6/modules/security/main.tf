locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "security"
  }
}

resource "aws_security_group" "web" {
  name        = "${var.environment}-task6-web-sg"
  description = "Allow HTTP and SSH access to web instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-task6-web-sg"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.environment}-task6-db-sg"
  description = "Allow MySQL only from web SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from web SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-task6-db-sg"
  })
}
