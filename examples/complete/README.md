# Complete Example

This example demonstrates how to use the MySQL RDS module to create a complete WordPress hosting environment with the following components:

- VPC and VSwitch for network isolation
- Security Group with appropriate rules
- ECS instance as web server
- RDS MySQL instance as database
- Automated WordPress installation via ECS command

## Usage

To run this example, you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create real resources in your Alibaba Cloud account, which may incur costs.

## Prerequisites

Before running this example, ensure you have:

1. Configured your Alibaba Cloud credentials
2. Terraform >= 1.0 installed
3. Sufficient permissions to create VPC, ECS, and RDS resources

## Password Requirements

Both `ecs_password` and `db_password` must:
- Be 8-30 characters long
- Contain at least three of the following character types:
  - Uppercase letters
  - Lowercase letters
  - Numbers
  - Special characters

## Database Username Requirements

The `db_username` must:
- Be 2-16 characters long
- Contain only lowercase letters, numbers, and underscores
- Start with a letter
- End with a letter or number

## After Deployment

1. Wait for the ECS command execution to complete (this may take several minutes)
2. Access WordPress via the public IP address shown in the `wordpress_url` output
3. Complete the WordPress setup using the database connection information provided in outputs

## Cleanup

To destroy the resources created by this example:

```bash
$ terraform destroy
```

## Notes

- The security group rule allows all traffic from any IP address (0.0.0.0/0). In production environments, you should restrict access to specific IP ranges.
- The RDS instance is created in Basic category for cost optimization. For production workloads, consider using HighAvailability category.
- WordPress installation is automated via ECS command, which includes downloading WordPress, configuring database connection, and starting necessary services.