provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Reuse network resources created in task1.
data "terraform_remote_state" "task1" {
  backend = "local"

  config = {
    path = "../task1/terraform.tfstate"
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  selected_ami_id   = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  vpc_id            = data.terraform_remote_state.task1.outputs.vpc_id
  public_subnet_id  = data.terraform_remote_state.task1.outputs.public_subnet_ids[0]
  private_subnet_id = data.terraform_remote_state.task1.outputs.private_subnet_ids[0]
}

resource "aws_security_group" "web" {
  name        = "assignment3-web-sg"
  description = "Public web server SG: HTTP/HTTPS + SSH from my IP"
  vpc_id      = local.vpc_id

  ingress {
    description = "HTTPS from my IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "assignment3-web-sg"
    Tier = "public"
  })
}

resource "aws_security_group" "db" {
  name        = "assignment3-db-sg"
  description = "Private DB SG: MySQL only from web SG"
  vpc_id      = local.vpc_id

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

  tags = merge(var.tags, {
    Name = "assignment3-db-sg"
    Tier = "private"
  })
}

# Separate SG to allow bastion SSH path while keeping DB SG restricted to MySQL only.
resource "aws_security_group" "private_ssh" {
  name        = "assignment3-private-ssh-from-web"
  description = "Allow SSH to private instance only from web SG"
  vpc_id      = local.vpc_id

  ingress {
    description     = "SSH from web SG"
    from_port       = 22
    to_port         = 22
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

  tags = merge(var.tags, {
    Name = "assignment3-private-ssh-from-web"
    Tier = "private"
  })
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

  tags = merge(var.tags, {
    Name = var.key_name
  })
}

resource "aws_instance" "web" {
  ami                         = local.selected_ami_id
  instance_type               = var.instance_type
  subnet_id                   = local.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data.sh")

  tags = merge(var.tags, {
    Name = "assignment3-web-instance"
    Role = "web"
  })
}

resource "aws_instance" "db" {
  ami                         = local.selected_ami_id
  instance_type               = var.instance_type
  subnet_id                   = local.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.db.id, aws_security_group.private_ssh.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = false

  tags = merge(var.tags, {
    Name = "assignment3-db-instance"
    Role = "db"
  })
}
