variable "ami_id" {
  description = "AMI ID used for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where instance will run"
  type        = string
}

variable "security_group_ids" {
  description = "Security Group IDs attached to instance"
  type        = list(string)
}

variable "key_name" {
  description = "Name of existing AWS key pair"
  type        = string
}

variable "environment" {
  description = "Environment name used for naming and tags"
  type        = string
}
