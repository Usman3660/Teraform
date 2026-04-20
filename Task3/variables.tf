variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Global prefix for S3 bucket name. A random suffix is added automatically."
  type        = string
  default     = "assignment3-tfstate"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,50}[a-z0-9]$", var.bucket_prefix))
    error_message = "bucket_prefix must be 3-52 chars, lowercase letters/numbers/hyphens, and must start/end with alphanumeric character."
  }
}

variable "roll_number" {
  description = "Your roll number (optional). If set, it is included in bucket naming to help uniqueness."
  type        = string
  default     = ""

  validation {
    condition     = var.roll_number == "" || can(regex("^[a-z0-9-]{2,20}$", var.roll_number))
    error_message = "roll_number must be empty or 2-20 chars using lowercase letters, numbers, or hyphens."
  }
}

variable "ec2_role_name" {
  description = "IAM role name for EC2 to access this bucket"
  type        = string
  default     = "assignment3-ec2-s3-role"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  type        = string
  default     = "assignment3-terraform-locks"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "Assignment-3"
    ManagedBy   = "Terraform"
    Environment = "lab"
    Task        = "Task3"
  }
}
