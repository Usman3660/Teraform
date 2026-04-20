variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "my_ip_cidr" {
  description = "Your public IPv4 in CIDR format (/32), used for SSH/HTTP/HTTPS access to the public web server"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/32$", var.my_ip_cidr))
    error_message = "my_ip_cidr must be a valid IPv4 /32 CIDR, e.g. 203.0.113.10/32."
  }
}

variable "instance_type" {
  description = "EC2 instance type for both instances"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "instance_type must be one of: t3.micro, t3.small, t3.medium."
  }
}

variable "ami_id" {
  description = "Optional AMI ID. Leave empty to auto-select the latest Amazon Linux 2023 AMI."
  type        = string
  default     = ""

  validation {
    condition     = var.ami_id == "" || can(regex("^ami-[0-9a-fA-F]{8,17}$", var.ami_id))
    error_message = "ami_id must be empty or a valid AMI ID like ami-1234567890abcdef0."
  }
}

variable "key_name" {
  description = "Name of the AWS key pair created by Terraform"
  type        = string
}

variable "public_key_path" {
  description = "Path to your local public key file (.pub) used to create aws_key_pair"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "Assignment-3"
    ManagedBy   = "Terraform"
    Environment = "lab"
    Task        = "Task2"
  }
}
