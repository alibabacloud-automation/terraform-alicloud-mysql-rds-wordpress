# VPC outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = alicloud_vpc.vpc.cidr_block
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = alicloud_vpc.vpc.vpc_name
}

# VSwitch outputs
output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = alicloud_vswitch.vswitch.id
}

output "vswitch_cidr_block" {
  description = "The CIDR block of the VSwitch"
  value       = alicloud_vswitch.vswitch.cidr_block
}

output "vswitch_zone_id" {
  description = "The availability zone of the VSwitch"
  value       = alicloud_vswitch.vswitch.zone_id
}

# Security Group outputs
output "security_group_id" {
  description = "The ID of the Security Group"
  value       = alicloud_security_group.security_group.id
}

output "security_group_name" {
  description = "The name of the Security Group"
  value       = alicloud_security_group.security_group.security_group_name
}

# ECS Instance outputs
output "ecs_instance_id" {
  description = "The ID of the ECS instance"
  value       = alicloud_instance.web_server.id
}

output "ecs_instance_name" {
  description = "The name of the ECS instance"
  value       = alicloud_instance.web_server.instance_name
}

output "ecs_instance_public_ip" {
  description = "The public IP address of the ECS instance"
  value       = alicloud_instance.web_server.public_ip
}

output "ecs_instance_private_ip" {
  description = "The private IP address of the ECS instance"
  value       = alicloud_instance.web_server.private_ip
}

# RDS Instance outputs
output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = alicloud_db_instance.database.id
}

output "rds_instance_name" {
  description = "The name of the RDS instance"
  value       = alicloud_db_instance.database.instance_name
}

output "rds_instance_connection_string" {
  description = "The connection string of the RDS instance"
  value       = alicloud_db_instance.database.connection_string
}

output "rds_instance_port" {
  description = "The port of the RDS instance"
  value       = alicloud_db_instance.database.port
}

output "rds_instance_engine" {
  description = "The engine type of the RDS instance"
  value       = alicloud_db_instance.database.engine
}

output "rds_instance_engine_version" {
  description = "The engine version of the RDS instance"
  value       = alicloud_db_instance.database.engine_version
}

# RDS Database outputs
output "rds_database_name" {
  description = "The name of the RDS database"
  value       = alicloud_db_database.wordpress_db.data_base_name
}

output "rds_database_character_set" {
  description = "The character set of the RDS database"
  value       = alicloud_db_database.wordpress_db.character_set
}

# RDS Account outputs
output "rds_account_name" {
  description = "The name of the RDS account"
  value       = alicloud_rds_account.db_user.account_name
}

output "rds_account_type" {
  description = "The type of the RDS account"
  value       = alicloud_rds_account.db_user.account_type
}

# ECS Command outputs
output "ecs_command_id" {
  description = "The ID of the ECS command"
  value       = alicloud_ecs_command.wordpress_install_command.id
}

output "ecs_command_name" {
  description = "The name of the ECS command"
  value       = alicloud_ecs_command.wordpress_install_command.name
}

# ECS Invocation outputs
output "ecs_invocation_id" {
  description = "The ID of the ECS invocation"
  value       = alicloud_ecs_invocation.wordpress_install_invocation.id
}

output "ecs_invocation_status" {
  description = "The status of the ECS invocation"
  value       = alicloud_ecs_invocation.wordpress_install_invocation.status
}

# Application access information
output "wordpress_url" {
  description = "The URL to access WordPress application"
  value       = alicloud_instance.web_server.public_ip != "" ? "http://${alicloud_instance.web_server.public_ip}" : "WordPress will be accessible via ECS public IP when available"
}

output "database_connection_info" {
  description = "Database connection information for WordPress"
  value = {
    host     = alicloud_db_instance.database.connection_string
    port     = alicloud_db_instance.database.port
    database = alicloud_db_database.wordpress_db.data_base_name
    username = alicloud_rds_account.db_user.account_name
  }
  sensitive = false
}