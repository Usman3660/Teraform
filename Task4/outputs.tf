output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "Latest Launch Template version"
  value       = aws_launch_template.this.latest_version
}

output "scale_out_policy_arn" {
  description = "ARN of the scale-out policy"
  value       = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  description = "ARN of the scale-in policy"
  value       = aws_autoscaling_policy.scale_in.arn
}

output "cpu_high_alarm_name" {
  description = "CloudWatch alarm name for scale-out"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "cpu_low_alarm_name" {
  description = "CloudWatch alarm name for scale-in"
  value       = aws_cloudwatch_metric_alarm.cpu_low.alarm_name
}
