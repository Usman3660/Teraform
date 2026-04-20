locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "compute"
  }
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${var.environment}-task6-web-instance"
  })
}
