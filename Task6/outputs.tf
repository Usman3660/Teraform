output "vpc_id" {
  description = "VPC ID from vpc module"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs from vpc module"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs from vpc module"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID from vpc module"
  value       = module.vpc.nat_gateway_id
}

output "web_sg_id" {
  description = "Web SG ID from security module"
  value       = module.security.web_sg_id
}

output "db_sg_id" {
  description = "DB SG ID from security module"
  value       = module.security.db_sg_id
}

output "compute_instance_id" {
  description = "Instance ID from compute module"
  value       = module.compute.instance_id
}

output "compute_public_ip" {
  description = "Public IP from compute module"
  value       = module.compute.public_ip
}
