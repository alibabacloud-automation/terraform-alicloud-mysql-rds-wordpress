# Local variables for default configurations
locals {
  # Default WordPress installation script
  default_wordpress_install_script = <<-EOF
#!/bin/sh
DatabaseUser='${var.db_user_name}'
DatabasePwd='${var.db_password}'
DatabaseName='${var.db_database_config.name}'
DatabaseHost='${alicloud_db_instance.database.connection_string}'
yum update -y
yum install -y unzip zip
yum install -y mysql-server
systemctl start mysqld
systemctl enable mysqld
mysql -h $DatabaseHost -u $DatabaseUser -p$DatabasePwd -e "CREATE DATABASE IF NOT EXISTS $DatabaseName;"
mysql -h $DatabaseHost -u $DatabaseUser -p$DatabasePwd -e "USE $DatabaseName;"
yum install -y nginx
systemctl start nginx
systemctl enable nginx
yum install -y php php-fpm php-mysqlnd
systemctl start php-fpm
systemctl enable php-fpm
cd /usr/share/nginx/html
wget https://help-static-aliyun-doc.aliyuncs.com/file-manage-files/zh-CN/20240726/hhvpuw/wordpress-6.6.1.tar
tar -xvf wordpress-6.6.1.tar
cp -R wordpress/* .
rm -R wordpress
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/$DatabaseName/" wp-config.php
sed -i "s/username_here/$DatabaseUser/" wp-config.php
sed -i "s/password_here/$DatabasePwd/" wp-config.php
sed -i "s/localhost/$DatabaseHost/" wp-config.php
systemctl restart nginx
systemctl restart php-fpm
EOF
}

# VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = var.vpc_config.vpc_name
  cidr_block = var.vpc_config.cidr_block

  tags = var.common_tags
}

# VSwitch
resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = var.vswitch_config.cidr_block
  zone_id      = var.vswitch_config.zone_id
  vswitch_name = var.vswitch_config.vswitch_name

  tags = var.common_tags
}

# Security Group
resource "alicloud_security_group" "security_group" {
  security_group_name = var.security_group_config.security_group_name
  vpc_id              = alicloud_vpc.vpc.id
  description         = var.security_group_config.description

  tags = var.common_tags
}

# Security Group Rules - Allow specified traffic
resource "alicloud_security_group_rule" "security_group_ingress" {
  for_each = var.security_group_rule_config

  security_group_id = alicloud_security_group.security_group.id
  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  port_range        = each.value.port_range
  cidr_ip           = each.value.cidr_ip
  policy            = each.value.policy
  priority          = each.value.priority
}

# ECS Instance (WebServer)
resource "alicloud_instance" "web_server" {
  instance_name              = var.instance_config.instance_name
  image_id                   = var.instance_config.image_id
  instance_type              = var.instance_config.instance_type
  security_groups            = [alicloud_security_group.security_group.id]
  vswitch_id                 = alicloud_vswitch.vswitch.id
  system_disk_category       = var.instance_config.system_disk_category
  system_disk_size           = var.instance_config.system_disk_size
  internet_max_bandwidth_out = var.instance_config.internet_max_bandwidth_out
  password                   = var.instance_config.password
  instance_charge_type       = var.instance_config.instance_charge_type
  availability_zone          = alicloud_vswitch.vswitch.zone_id

  tags = var.common_tags
}

# RDS Instance (Database)
resource "alicloud_db_instance" "database" {
  engine                   = var.db_instance_config.engine
  engine_version           = var.db_instance_config.engine_version
  instance_type            = var.db_instance_config.instance_type
  instance_storage         = var.db_instance_config.instance_storage
  vpc_id                   = alicloud_vpc.vpc.id
  vswitch_id               = alicloud_vswitch.vswitch.id
  security_group_ids       = [alicloud_security_group.security_group.id]
  security_ips             = [alicloud_instance.web_server.private_ip]
  zone_id                  = alicloud_vswitch.vswitch.zone_id
  instance_charge_type     = var.db_instance_config.instance_charge_type
  category                 = var.db_instance_config.category
  instance_name            = var.db_instance_config.instance_name
  db_instance_storage_type = var.db_instance_config.db_instance_storage_type
  monitoring_period        = var.db_instance_config.monitoring_period
  period                   = var.db_instance_config.period
  auto_renew               = var.db_instance_config.auto_renew

  tags = var.common_tags
}

# RDS Database
resource "alicloud_db_database" "wordpress_db" {
  instance_id    = alicloud_db_instance.database.id
  data_base_name = var.db_database_config.name
  character_set  = var.db_database_config.character_set
  description    = var.db_database_config.description
}

# RDS Account
resource "alicloud_rds_account" "db_user" {
  db_instance_id      = alicloud_db_instance.database.id
  account_name        = var.db_user_name
  account_password    = var.db_password
  account_type        = var.rds_account_config.account_type
  account_description = var.rds_account_config.account_description
}

# ECS Command for WordPress installation
resource "alicloud_ecs_command" "wordpress_install_command" {
  name             = var.ecs_command_config.name
  description      = var.ecs_command_config.description
  enable_parameter = var.ecs_command_config.enable_parameter
  type             = var.ecs_command_config.type
  command_content  = var.custom_wordpress_install_script != null ? var.custom_wordpress_install_script : base64encode(local.default_wordpress_install_script)
  timeout          = var.ecs_command_config.timeout
  working_dir      = var.ecs_command_config.working_dir
}

# Execute command on ECS instance
resource "alicloud_ecs_invocation" "wordpress_install_invocation" {
  instance_id = [alicloud_instance.web_server.id]
  command_id  = alicloud_ecs_command.wordpress_install_command.id

  depends_on = [
    alicloud_security_group_rule.security_group_ingress,
    alicloud_db_database.wordpress_db,
    alicloud_rds_account.db_user
  ]

  timeouts {
    create = "60m"
  }
}