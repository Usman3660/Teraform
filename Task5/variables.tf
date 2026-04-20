variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "Assignment-3"
    ManagedBy   = "Terraform"
    Environment = "lab"
    Task        = "Task5"
  }
}
