variable "region" {
  description = "The Alibaba Cloud region where resources will be created"
  type        = string
  default     = "cn-hangzhou"
}

variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "mysql-rds-example"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "ecs_password" {
  description = "Password for ECS instance. Must be 8-30 characters and contain at least three of: uppercase letters, lowercase letters, numbers, special characters."
  type        = string
  default     = "Password123!"
  sensitive   = true

  validation {
    condition     = length(var.ecs_password) >= 8 && length(var.ecs_password) <= 30
    error_message = "ECS password must be between 8 and 30 characters."
  }
}

variable "db_username" {
  description = "Database username. Must be 2-16 lowercase letters, underscores allowed. Must start with a letter and end with a letter or number."
  type        = string
  default     = "wpuser"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]{0,14}[a-z0-9]$", var.db_username)) && length(var.db_username) >= 2 && length(var.db_username) <= 16
    error_message = "Database username must be 2-16 characters, lowercase letters and underscores only, must start with a letter and end with a letter or number."
  }
}

variable "db_password" {
  description = "Database password. Must be 8-30 characters and contain at least three of: uppercase letters, lowercase letters, numbers, special characters."
  type        = string
  default     = "DBPassword123!"
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8 && length(var.db_password) <= 30
    error_message = "Database password must be between 8 and 30 characters."
  }
}