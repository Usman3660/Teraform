output "terraform_state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "ec2_role_name" {
  description = "IAM role that grants EC2 read/write access to this bucket"
  value       = aws_iam_role.ec2_s3_access.name
}

output "ec2_instance_profile_name" {
  description = "IAM instance profile for attaching the role to EC2 instances"
  value       = aws_iam_instance_profile.ec2_s3_access.name
}
