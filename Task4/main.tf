provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Reuse the VPC and public subnets from Task 1.
data "terraform_remote_state" "task1" {
  backend = "local"

  config = {
    path = "../Task1/terraform.tfstate"
  }
}

# Reuse the web Security Group and key pair from Task 2.
data "terraform_remote_state" "task2" {
  backend = "local"

  config = {
    path = "../Task2/terraform.tfstate"
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
  selected_ami_id       = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  vpc_id                = data.terraform_remote_state.task1.outputs.vpc_id
  public_subnet_ids     = data.terraform_remote_state.task1.outputs.public_subnet_ids
  web_security_group_id = data.terraform_remote_state.task2.outputs.web_security_group_id
  key_pair_name         = data.terraform_remote_state.task2.outputs.key_pair_name
}

resource "aws_launch_template" "this" {
  name_prefix   = "assignment3-task4-lt-"
  image_id      = local.selected_ami_id
  instance_type = var.instance_type
  key_name      = local.key_pair_name

  vpc_security_group_ids = [local.web_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {}))

  update_default_version = true

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "assignment3-task4-asg-instance"
      Role = "web"
    })
  }

  tags = merge(var.tags, {
    Name = "assignment3-task4-launch-template"
  })
}

resource "aws_autoscaling_group" "this" {
  name                      = "assignment3-task4-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  vpc_zone_identifier       = local.public_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "assignment3-task4-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "web"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = lookup(var.tags, "Project", "Assignment-3")
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = lookup(var.tags, "Environment", "lab")
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = lookup(var.tags, "ManagedBy", "Terraform")
    propagate_at_launch = true
  }

  tag {
    key                 = "Task"
    value               = lookup(var.tags, "Task", "Task4")
    propagate_at_launch = true
  }

  depends_on = [aws_launch_template.this]
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "assignment3-task4-scale-out"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "assignment3-task4-scale-in"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "assignment3-task4-cpu-high"
  alarm_description   = "Scale out when average CPUUtilization is 60% or higher for two consecutive minutes."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 60
  period              = 60
  statistic           = "Average"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }
  alarm_actions      = [aws_autoscaling_policy.scale_out.arn]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "assignment3-task4-cpu-low"
  alarm_description   = "Scale in when average CPUUtilization is 20% or lower for two consecutive minutes."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 20
  period              = 60
  statistic           = "Average"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }
  alarm_actions      = [aws_autoscaling_policy.scale_in.arn]
  treat_missing_data = "notBreaching"
}
