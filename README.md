Terraform Module for MySQL RDS WordPress Solution on Alibaba Cloud

# terraform-alicloud-mysql-rds-wordpress

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-mysql-rds-wordpress/blob/main/README-CN.md)

This Terraform module creates a complete WordPress hosting solution on Alibaba Cloud using MySQL RDS as the database backend. The module provisions a VPC network, ECS instance as web server, RDS MySQL database, and automatically installs and configures WordPress with proper database connectivity. This solution is ideal for small to medium-sized websites requiring a reliable, scalable, and cost-effective hosting environment. For more information about database migration and WordPress hosting solutions, see [Database Migration Solutions](https://www.alibabacloud.com/solutions/database-migration).

## Usage

The following example shows how to create a complete WordPress hosting environment with MySQL RDS:

```terraform
data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_instance_types" "default" {
  availability_zone = data.alicloud_zones.default.zones[0].id
  cpu_core_count    = 2
  memory_size       = 4
}

data "alicloud_images" "default" {
  name_regex  = "^ubuntu_18.*64"
  most_recent = true
  owners      = "system"
}

data "alicloud_db_instance_classes" "default" {
  zone_id                  = data.alicloud_zones.default.zones[0].id
  engine                   = "MySQL"
  engine_version           = "8.0"
  category                 = "Basic"
  db_instance_storage_type = "cloud_essd"
}

module "mysql_rds_wordpress" {
  source = "alibabacloud-automation/mysql-rds-wordpress/alicloud"

  vpc_config = {
    cidr_block = "192.168.0.0/16"
  }

  vswitch_config = {
    cidr_block = "192.168.0.0/24"
    zone_id    = data.alicloud_zones.default.zones[0].id
  }

  instance_config = {
    image_id             = data.alicloud_images.default.images[0].id
    instance_type        = data.alicloud_instance_types.default.instance_types[0].id
    system_disk_category = "cloud_efficiency"
    password             = "YourSecurePassword123!"
  }

  db_instance_config = {
    instance_type    = data.alicloud_db_instance_classes.default.instance_classes[0].instance_class
    instance_storage = 20
  }

  db_password = "YourDBPassword123!"
}
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-mysql-rds-wordpress/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.155.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | 1.272.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_db_database.wordpress_db](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/db_database) | resource |
| [alicloud_db_instance.database](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/db_instance) | resource |
| [alicloud_ecs_command.wordpress_install_command](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_invocation.wordpress_install_invocation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_instance.web_server](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_rds_account.db_user](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/rds_account) | resource |
| [alicloud_security_group.security_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.security_group_ingress](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_vpc.vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | A map of tags to assign to all resources | `map(string)` | `{}` | no |
| <a name="input_custom_wordpress_install_script"></a> [custom\_wordpress\_install\_script](#input\_custom\_wordpress\_install\_script) | Custom WordPress installation script (base64 encoded). If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_db_database_config"></a> [db\_database\_config](#input\_db\_database\_config) | Configuration for RDS database | <pre>object({<br/>    name          = optional(string, "wordpressdb")<br/>    character_set = optional(string, "utf8mb4")<br/>    description   = optional(string, "WordPress database for migration test")<br/>  })</pre> | `{}` | no |
| <a name="input_db_instance_config"></a> [db\_instance\_config](#input\_db\_instance\_config) | Configuration for RDS instance. The attributes 'engine', 'engine\_version', 'instance\_type', and 'instance\_storage' are required. | <pre>object({<br/>    engine                   = optional(string, "MySQL")<br/>    engine_version           = optional(string, "8.0")<br/>    instance_type            = string<br/>    instance_storage         = number<br/>    instance_charge_type     = optional(string, "Postpaid")<br/>    category                 = optional(string, "Basic")<br/>    instance_name            = optional(string, "mysql-rds-database")<br/>    db_instance_storage_type = optional(string, "cloud_essd")<br/>    monitoring_period        = optional(number, 60)<br/>    period                   = optional(number, 1)<br/>    auto_renew               = optional(bool, false)<br/>  })</pre> | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | RDS database password. Must be 8-30 characters and contain at least three of: uppercase letters, lowercase letters, numbers, special characters. | `string` | n/a | yes |
| <a name="input_db_user_name"></a> [db\_user\_name](#input\_db\_user\_name) | RDS database account name. Must be 2-16 lowercase letters, underscores allowed. Must start with a letter and end with a letter or number. | `string` | `"dbuser"` | no |
| <a name="input_ecs_command_config"></a> [ecs\_command\_config](#input\_ecs\_command\_config) | Configuration for ECS command | <pre>object({<br/>    name             = optional(string, "wordpress-install-command")<br/>    description      = optional(string, "Install WordPress and MySQL on ECS instance")<br/>    enable_parameter = optional(bool, false)<br/>    type             = optional(string, "RunShellScript")<br/>    timeout          = optional(number, 3600)<br/>    working_dir      = optional(string, "/root")<br/>  })</pre> | `{}` | no |
| <a name="input_instance_config"></a> [instance\_config](#input\_instance\_config) | Configuration for ECS instance. The attributes 'image\_id', 'instance\_type', 'system\_disk\_category', and 'password' are required. | <pre>object({<br/>    instance_name              = optional(string, "mysql-rds-webserver")<br/>    image_id                   = string<br/>    instance_type              = string<br/>    system_disk_category       = string<br/>    system_disk_size           = optional(number, 40)<br/>    internet_max_bandwidth_out = optional(number, 80)<br/>    password                   = string<br/>    instance_charge_type       = optional(string, "PostPaid")<br/>  })</pre> | n/a | yes |
| <a name="input_rds_account_config"></a> [rds\_account\_config](#input\_rds\_account\_config) | Configuration for RDS account | <pre>object({<br/>    account_type        = optional(string, "Super")<br/>    account_description = optional(string, "Database user for WordPress")<br/>  })</pre> | `{}` | no |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | Configuration for Security Group | <pre>object({<br/>    security_group_name = optional(string, "mysql-rds-security-group")<br/>    description         = optional(string, "Security group for MySQL RDS solution")<br/>  })</pre> | `{}` | no |
| <a name="input_security_group_rule_config"></a> [security\_group\_rule\_config](#input\_security\_group\_rule\_config) | Configuration for Security Group Rules (map of objects) | <pre>map(object({<br/>    type        = optional(string, "ingress")<br/>    ip_protocol = optional(string, "all")<br/>    port_range  = optional(string, "-1/-1")<br/>    cidr_ip     = optional(string, "0.0.0.0/0")<br/>    policy      = optional(string, "accept")<br/>    priority    = optional(number, 1)<br/>  }))</pre> | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | Configuration for VPC. The attribute 'cidr\_block' is required. | <pre>object({<br/>    vpc_name   = optional(string, "mysql-rds-vpc")<br/>    cidr_block = string<br/>  })</pre> | n/a | yes |
| <a name="input_vswitch_config"></a> [vswitch\_config](#input\_vswitch\_config) | Configuration for VSwitch. The attributes 'cidr\_block' and 'zone\_id' are required. | <pre>object({<br/>    vswitch_name = optional(string, "mysql-rds-vswitch")<br/>    cidr_block   = string<br/>    zone_id      = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_connection_info"></a> [database\_connection\_info](#output\_database\_connection\_info) | Database connection information for WordPress |
| <a name="output_ecs_command_id"></a> [ecs\_command\_id](#output\_ecs\_command\_id) | The ID of the ECS command |
| <a name="output_ecs_command_name"></a> [ecs\_command\_name](#output\_ecs\_command\_name) | The name of the ECS command |
| <a name="output_ecs_instance_id"></a> [ecs\_instance\_id](#output\_ecs\_instance\_id) | The ID of the ECS instance |
| <a name="output_ecs_instance_name"></a> [ecs\_instance\_name](#output\_ecs\_instance\_name) | The name of the ECS instance |
| <a name="output_ecs_instance_private_ip"></a> [ecs\_instance\_private\_ip](#output\_ecs\_instance\_private\_ip) | The private IP address of the ECS instance |
| <a name="output_ecs_instance_public_ip"></a> [ecs\_instance\_public\_ip](#output\_ecs\_instance\_public\_ip) | The public IP address of the ECS instance |
| <a name="output_ecs_invocation_id"></a> [ecs\_invocation\_id](#output\_ecs\_invocation\_id) | The ID of the ECS invocation |
| <a name="output_ecs_invocation_status"></a> [ecs\_invocation\_status](#output\_ecs\_invocation\_status) | The status of the ECS invocation |
| <a name="output_rds_account_name"></a> [rds\_account\_name](#output\_rds\_account\_name) | The name of the RDS account |
| <a name="output_rds_account_type"></a> [rds\_account\_type](#output\_rds\_account\_type) | The type of the RDS account |
| <a name="output_rds_database_character_set"></a> [rds\_database\_character\_set](#output\_rds\_database\_character\_set) | The character set of the RDS database |
| <a name="output_rds_database_name"></a> [rds\_database\_name](#output\_rds\_database\_name) | The name of the RDS database |
| <a name="output_rds_instance_connection_string"></a> [rds\_instance\_connection\_string](#output\_rds\_instance\_connection\_string) | The connection string of the RDS instance |
| <a name="output_rds_instance_engine"></a> [rds\_instance\_engine](#output\_rds\_instance\_engine) | The engine type of the RDS instance |
| <a name="output_rds_instance_engine_version"></a> [rds\_instance\_engine\_version](#output\_rds\_instance\_engine\_version) | The engine version of the RDS instance |
| <a name="output_rds_instance_id"></a> [rds\_instance\_id](#output\_rds\_instance\_id) | The ID of the RDS instance |
| <a name="output_rds_instance_name"></a> [rds\_instance\_name](#output\_rds\_instance\_name) | The name of the RDS instance |
| <a name="output_rds_instance_port"></a> [rds\_instance\_port](#output\_rds\_instance\_port) | The port of the RDS instance |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the Security Group |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the Security Group |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC |
| <a name="output_vswitch_cidr_block"></a> [vswitch\_cidr\_block](#output\_vswitch\_cidr\_block) | The CIDR block of the VSwitch |
| <a name="output_vswitch_id"></a> [vswitch\_id](#output\_vswitch\_id) | The ID of the VSwitch |
| <a name="output_vswitch_zone_id"></a> [vswitch\_zone\_id](#output\_vswitch\_zone\_id) | The availability zone of the VSwitch |
| <a name="output_wordpress_url"></a> [wordpress\_url](#output\_wordpress\_url) | The URL to access WordPress application |
<!-- END_TF_DOCS -->

## Submit Issues

If you have any problems when using this module, please opening
a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend opening an issue on this repo.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)