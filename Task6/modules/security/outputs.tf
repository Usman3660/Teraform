output "web_sg_id" {
  description = "Web security group ID"
  value       = aws_security_group.web.id
}

output "db_sg_id" {
  description = "DB security group ID"
  value       = aws_security_group.db.id
}
