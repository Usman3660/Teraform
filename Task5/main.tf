provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Reuse VPC and public subnets from Task 1.
data "terraform_remote_state" "task1" {
  backend = "local"

  config = {
    path = "../Task1/terraform.tfstate"
  }
}

# Reuse web Security Group from Task 2.
data "terraform_remote_state" "task2" {
  backend = "local"

  config = {
    path = "../Task2/terraform.tfstate"
  }
}

# Reuse Auto Scaling Group from Task 4.
data "terraform_remote_state" "task4" {
  backend = "local"

  config = {
    path = "../Task4/terraform.tfstate"
  }
}

locals {
  vpc_id            = data.terraform_remote_state.task1.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.task1.outputs.public_subnet_ids
  web_sg_id         = data.terraform_remote_state.task2.outputs.web_security_group_id
  asg_name          = data.terraform_remote_state.task4.outputs.autoscaling_group_name
}

resource "aws_security_group" "alb" {
  name        = "assignment3-task5-alb-sg"
  description = "Allow HTTP from internet to ALB"
  vpc_id      = local.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
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

  tags = merge(var.tags, {
    Name = "assignment3-task5-alb-sg"
  })
}

# Web instances can receive HTTP only from the ALB SG.
resource "aws_security_group_rule" "web_http_from_alb" {
  type                     = "ingress"
  description              = "HTTP from ALB SG"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = local.web_sg_id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_lb" "this" {
  name               = "assignment3-task5-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.public_subnet_ids

  tags = merge(var.tags, {
    Name = "assignment3-task5-alb"
  })
}

resource "aws_lb_target_group" "this" {
  name        = "assignment3-task5-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name = "assignment3-task5-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_autoscaling_attachment" "asg_to_tg" {
  autoscaling_group_name = local.asg_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}
