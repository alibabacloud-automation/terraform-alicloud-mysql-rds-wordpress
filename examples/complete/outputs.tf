# VPC outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.mysql_rds.vpc_id
}

output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = module.mysql_rds.vswitch_id
}

# ECS Instance outputs
output "ecs_instance_id" {
  description = "The ID of the ECS instance"
  value       = module.mysql_rds.ecs_instance_id
}

output "ecs_instance_public_ip" {
  description = "The public IP address of the ECS instance"
  value       = module.mysql_rds.ecs_instance_public_ip
}

output "ecs_instance_private_ip" {
  description = "The private IP address of the ECS instance"
  value       = module.mysql_rds.ecs_instance_private_ip
}

# RDS Instance outputs
output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = module.mysql_rds.rds_instance_id
}

output "rds_instance_connection_string" {
  description = "The connection string of the RDS instance"
  value       = module.mysql_rds.rds_instance_connection_string
}

output "rds_database_name" {
  description = "The name of the RDS database"
  value       = module.mysql_rds.rds_database_name
}

# Application access information
output "wordpress_url" {
  description = "The URL to access WordPress application"
  value       = module.mysql_rds.wordpress_url
}

output "database_connection_info" {
  description = "Database connection information for WordPress"
  value       = module.mysql_rds.database_connection_info
  sensitive   = false
}

# Security Group outputs
output "security_group_id" {
  description = "The ID of the Security Group"
  value       = module.mysql_rds.security_group_id
}

# ECS Command outputs
output "ecs_command_id" {
  description = "The ID of the ECS command"
  value       = module.mysql_rds.ecs_command_id
}

output "ecs_invocation_id" {
  description = "The ID of the ECS invocation"
  value       = module.mysql_rds.ecs_invocation_id
}

output "ecs_invocation_status" {
  description = "The status of the ECS invocation"
  value       = module.mysql_rds.ecs_invocation_status
}