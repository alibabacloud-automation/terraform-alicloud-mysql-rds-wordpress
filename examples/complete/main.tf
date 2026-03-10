# Provider configuration
provider "alicloud" {
  region = var.region
}

# Data sources to get available zones and instance types


data "alicloud_instance_types" "default" {
  availability_zone = data.alicloud_db_zones.default.ids[1]
  cpu_core_count    = 2
  memory_size       = 4
}

data "alicloud_images" "default" {
  name_regex    = "^aliyun_3_x64_20G_alibase_*"
  most_recent   = true
  owners        = "system"
  instance_type = data.alicloud_instance_types.default.instance_types[0].id
}

data "alicloud_db_zones" "default" {
  engine                   = "MySQL"
  engine_version           = "8.0"
  instance_charge_type     = "PostPaid"
  category                 = "HighAvailability"
  db_instance_storage_type = "cloud_essd"
}

locals {
  zone_id = data.alicloud_db_zones.default.zones[length(data.alicloud_db_zones.default.zones) - 1].id
}

data "alicloud_db_instance_classes" "example" {
  zone_id                  = local.zone_id
  engine                   = data.alicloud_db_zones.default.engine
  engine_version           = data.alicloud_db_zones.default.engine_version
  category                 = data.alicloud_db_zones.default.category
  db_instance_storage_type = data.alicloud_db_zones.default.db_instance_storage_type
  instance_charge_type     = data.alicloud_db_zones.default.instance_charge_type
}

# Call the MySQL RDS module
module "mysql_rds" {
  source = "../../"

  # VPC configuration
  vpc_config = {
    vpc_name   = var.name
    cidr_block = "192.168.0.0/16"
  }

  # VSwitch configuration
  vswitch_config = {
    vswitch_name = "${var.name}-vswitch"
    cidr_block   = "192.168.0.0/24"
    zone_id      = local.zone_id
  }

  # Security Group configuration
  security_group_config = {
    security_group_name = "${var.name}-sg"
    description         = "Security group for MySQL RDS example"
  }

  # Security Group Rules configuration (map of objects)
  security_group_rule_config = {
    ssh_rule = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "22/22"
      cidr_ip     = "192.168.0.0/16"
      policy      = "accept"
      priority    = 1
    },
    http_rule = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "192.168.0.0/16"
      policy      = "accept"
      priority    = 2
    },
    https_rule = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "443/443"
      cidr_ip     = "192.168.0.0/16"
      policy      = "accept"
      priority    = 3
    }
  }

  # ECS Instance configuration
  instance_config = {
    instance_name              = "${var.name}-webserver"
    image_id                   = data.alicloud_images.default.images[0].id
    instance_type              = data.alicloud_instance_types.default.instance_types[0].id
    system_disk_category       = "cloud_efficiency"
    system_disk_size           = 40
    internet_max_bandwidth_out = 80
    password                   = var.ecs_password
    instance_charge_type       = "PostPaid"
  }

  # RDS Instance configuration
  db_instance_config = {
    engine           = data.alicloud_db_instance_classes.example.engine
    engine_version   = data.alicloud_db_instance_classes.example.engine_version
    instance_type    = data.alicloud_db_instance_classes.example.instance_classes[0].instance_class
    instance_storage = data.alicloud_db_instance_classes.example.instance_classes[0].storage_range.min

    instance_charge_type     = "Postpaid"
    category                 = data.alicloud_db_instance_classes.example.category
    instance_name            = "${var.name}-mysql"
    db_instance_storage_type = "cloud_essd"
    monitoring_period        = 60
  }

  # Database configuration
  db_database_config = {
    name          = "wordpressdb"
    character_set = "utf8mb4"
    description   = "WordPress database for example"
  }

  # Database user configuration
  db_user_name = var.db_username
  db_password  = var.db_password

  # ECS Command configuration
  ecs_command_config = {
    name             = "${var.name}-wordpress-install"
    description      = "Install WordPress and configure MySQL connection"
    enable_parameter = false
    type             = "RunShellScript"
    timeout          = 3600
    working_dir      = "/root"
  }

  # Common tags
  common_tags = {
    Environment = var.environment
    Project     = var.name
    ManagedBy   = "Terraform"
  }
}