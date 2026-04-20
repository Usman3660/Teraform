output "web_security_group_id" {
  description = "Security Group ID for web instance"
  value       = aws_security_group.web.id
}

output "db_security_group_id" {
  description = "Security Group ID for DB instance"
  value       = aws_security_group.db.id
}

output "private_ssh_security_group_id" {
  description = "Security Group ID allowing SSH from web instance to private instance"
  value       = aws_security_group.private_ssh.id
}

output "key_pair_name" {
  description = "Created key pair name"
  value       = aws_key_pair.this.key_name
}

output "web_instance_id" {
  description = "Web EC2 instance ID"
  value       = aws_instance.web.id
}

output "web_public_ip" {
  description = "Public IP of web EC2 instance"
  value       = aws_instance.web.public_ip
}

output "web_public_dns" {
  description = "Public DNS of web EC2 instance"
  value       = aws_instance.web.public_dns
}

output "db_instance_id" {
  description = "Private DB EC2 instance ID"
  value       = aws_instance.db.id
}

output "db_private_ip" {
  description = "Private IP of DB EC2 instance"
  value       = aws_instance.db.private_ip
}
