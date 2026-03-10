# Common configuration
variable "common_tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# VPC configuration
variable "vpc_config" {
  description = "Configuration for VPC. The attribute 'cidr_block' is required."
  type = object({
    vpc_name   = optional(string, "mysql-rds-vpc")
    cidr_block = string
  })
}

# VSwitch configuration
variable "vswitch_config" {
  description = "Configuration for VSwitch. The attributes 'cidr_block' and 'zone_id' are required."
  type = object({
    vswitch_name = optional(string, "mysql-rds-vswitch")
    cidr_block   = string
    zone_id      = string
  })
}

# Security Group configuration
variable "security_group_config" {
  description = "Configuration for Security Group"
  type = object({
    security_group_name = optional(string, "mysql-rds-security-group")
    description         = optional(string, "Security group for MySQL RDS solution")
  })
  default = {}
}

# Security Group Rule configuration
variable "security_group_rule_config" {
  description = "Configuration for Security Group Rules (map of objects)"
  type = map(object({
    type        = optional(string, "ingress")
    ip_protocol = optional(string, "all")
    port_range  = optional(string, "-1/-1")
    cidr_ip     = optional(string, "0.0.0.0/0")
    policy      = optional(string, "accept")
    priority    = optional(number, 1)
  }))
  default = {}
}

# ECS Instance configuration
variable "instance_config" {
  description = "Configuration for ECS instance. The attributes 'image_id', 'instance_type', 'system_disk_category', and 'password' are required."
  type = object({
    instance_name              = optional(string, "mysql-rds-webserver")
    image_id                   = string
    instance_type              = string
    system_disk_category       = string
    system_disk_size           = optional(number, 40)
    internet_max_bandwidth_out = optional(number, 80)
    password                   = string
    instance_charge_type       = optional(string, "PostPaid")
  })
}

# RDS Instance configuration
variable "db_instance_config" {
  description = "Configuration for RDS instance. The attributes 'engine', 'engine_version', 'instance_type', and 'instance_storage' are required."
  type = object({
    engine                   = optional(string, "MySQL")
    engine_version           = optional(string, "8.0")
    instance_type            = string
    instance_storage         = number
    instance_charge_type     = optional(string, "Postpaid")
    category                 = optional(string, "Basic")
    instance_name            = optional(string, "mysql-rds-database")
    db_instance_storage_type = optional(string, "cloud_essd")
    monitoring_period        = optional(number, 60)
    period                   = optional(number, 1)
    auto_renew               = optional(bool, false)
  })
}

# RDS Database configuration
variable "db_database_config" {
  description = "Configuration for RDS database"
  type = object({
    name          = optional(string, "wordpressdb")
    character_set = optional(string, "utf8mb4")
    description   = optional(string, "WordPress database for migration test")
  })
  default = {}
}

# RDS Account configuration
variable "rds_account_config" {
  description = "Configuration for RDS account"
  type = object({
    account_type        = optional(string, "Super")
    account_description = optional(string, "Database user for WordPress")
  })
  default = {}
}

# Database user name
variable "db_user_name" {
  description = "RDS database account name. Must be 2-16 lowercase letters, underscores allowed. Must start with a letter and end with a letter or number."
  type        = string
  default     = "dbuser"
}

# Database password
variable "db_password" {
  description = "RDS database password. Must be 8-30 characters and contain at least three of: uppercase letters, lowercase letters, numbers, special characters."
  type        = string
  sensitive   = true
}

# ECS Command configuration
variable "ecs_command_config" {
  description = "Configuration for ECS command"
  type = object({
    name             = optional(string, "wordpress-install-command")
    description      = optional(string, "Install WordPress and MySQL on ECS instance")
    enable_parameter = optional(bool, false)
    type             = optional(string, "RunShellScript")
    timeout          = optional(number, 3600)
    working_dir      = optional(string, "/root")
  })
  default = {}
}

# Custom WordPress installation script
variable "custom_wordpress_install_script" {
  description = "Custom WordPress installation script (base64 encoded). If not provided, the default script will be used."
  type        = string
  default     = null
}