packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.9"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

source "amazon-ebs" "ubuntu_nginx" {
  region        = var.aws_region
  instance_type = "t3.micro"
  ssh_username  = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ami_name      = "assignment3-task6-nginx-{{timestamp}}"
  ami_description = "Custom Ubuntu AMI with nginx and curl for Assignment 3 Task 6"
}

build {
  name    = "assignment3-task6-custom-ami"
  sources = ["source.amazon-ebs.ubuntu_nginx"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx curl",
      "echo '<h1>Welcome from Task 6 custom Packer AMI</h1>' | sudo tee /var/www/html/index.html",
      "sudo systemctl enable nginx",
      "sudo systemctl restart nginx"
    ]
  }
}
