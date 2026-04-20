output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "alb_security_group_id" {
  description = "Security Group ID attached to the ALB"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "Target Group ARN used by the ALB listener"
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  description = "Target Group name"
  value       = aws_lb_target_group.this.name
}
