# Flight Booking Infrastructure
This repository contains the Terraform configuration for deploying the infrastructure of the Flight Booking system on AWS.

## Overview
The project provisions the core cloud resources required to run a simple flight booking application, including:

- An EC2 instance for the backend service
- An RDS MySQL database
- An S3 bucket for frontend static hosting
- An S3 bucket for user avatar storage
- Security groups for application and database access

## Architecture
The infrastructure currently includes:
- 'EC2'
    Hosts the backend application and exposes port `8000`.

- 'RDS MySQL'
    Stores application data.

- 'S3 frontend bucket'
    Used for static website hosting.

- 'S3 user avatar bucket'
    Stores uploaded user profile images.

- 'Security Groups'
    Control inbound and outbound traffic for the web and database tiers.

## Project Structure
.
├── README.md
└── terraform
    ├── backend.tf
    ├── main.tf
    ├── outputs.tf
    ├── variables.tf
    └── modules
        └── deploy.yaml

Prerequisites
Before using this project, make sure you have:
· Terraform >= 1.5.0
· An AWS account
· AWS credentials configured locally
· Permissions to create EC2, RDS, S3, VPC-related, and IAM-dependent resources

Usage 
Go to the Terraform directory:
```bash
cd terraform
```

Initialize Terraform:
```bash
terraform init
```

Review the execution plan:
```bash
terraform plan -var-file="envs/dev.tfvars"
```

Apply the infrastructure:
```bash
terraform apply -var-file="envs/dev.tfvars"
```

Input Variables
Key variables used in this project:
· aws_region
    AWS region for deployment. Default: eu-west-1
· project_name
    Project name prefix used in resource naming
· instance_type
    EC2 instance type for the backend server
· ssh_cidr
    CIDR block allowed to access the EC2 instance and database
· db_username
    Username for the MySQL database
· db_password
    Password for the MySQL database
· db_name
    Name of the MySQL database

Outputs
After deployment, Terraform provides:
· frontend_bucket_name
· user_avatars_name
· ec2_public_ip
· rds_mysql_endpoint
· rds_mysql_port

Notes
· This project currently uses the default AWS VPC and default subnets.
· The EC2 instance installs Docker and Git during bootstrapping
· The frontend S3 bucket is configured for static website hosting.
· ssh_cidr = 0.0.0.0/0 is not recommended for production environments
· Sensitive values such as database passwords and AWS credentials should not be committed to the repository.

Future Improvements
· Use a custom VPC instead of the default VPC
· Restrict ingress rules more securely
· Store secrets in AWS Secrets Manager or SSM Parameter Store
· Add remote Terraform state backend configuration
· Add CI/CD for infrastructure deployment
· Add CloudFront for frontend delivery

