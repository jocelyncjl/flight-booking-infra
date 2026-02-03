
# Terraform settings: version and providers
terraform {
    required_version = ">= 1.5.0"
    
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

locals {
    common_tags = {
        Project = var.project_name
        Env = "dev"
        Owner = "Jialing"
    }
}

# Query Default VPC & Subnet of AWS

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}


# Define Web Security Group web_sg
resource "aws_security_group" "web_sg" {
    name = "${var.project_name}-web-sg"
    description = "Security group for web (EC2) tier"
    vpc_id = data.aws_vpc.default.id

    # Allow the local IP connects to EC2
    ingress {
        description = "SSH from my IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.ssh_cidr]
    }

    # Allow all users to access HTTP 
    ingress {
        description = "HTTP from anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # All outbound permitted
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(local.common_tags, { Name = "${var.project_name}-web-sg"})
}

# Define Database Security Group db_sg
resource "aws_security_group" "db_sg" {
    name = "${var.project_name}-db-sg"
    description = "Security group for DB tier(MySQL RDS)"
    vpc_id = data.aws_vpc.default.id

    ingress {
        description = "MySQL from web_sg"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.web_sg.id]
    }

    # Allow the local laptop IP connect with the RDS MySQL
    ingress {
        description = "MySQl from my laptop(dev only)"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [var.ssh_cidr]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


# Create the random id for s3 bucket
resource "random_id" "suffix" {
    byte_length = 4
}


# Create S3 bucket for static website
resource "aws_s3_bucket" "frontend" {
    bucket = "${var.project_name}-frontend-${random_id.suffix.hex}"
    tags = merge(local.common_tags, { Name = "${var.project_name}-frontend"})
}

# Create S3 bucket for users avatar
resource "aws_s3_bucket" "user_avatars" {
    bucket = "${var.project_name}-user-avatar-${random_id.suffix.hex}"
    tags = merge(local.common_tags, {Name = "${var.project_name}-user-avatar"})
}


# Create S3 bucket static site hosting 
resource "aws_s3_bucket_website_configuration" "frontend_site" {
    bucket = aws_s3_bucket.frontend.id
    index_document {
        suffix = "index.html"
    }
    error_document {
        key = "index.html"
    }
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "db_subnets" {
    name = "${var.project_name}-db-subnets"
    subnet_ids = data.aws_subnets.default.ids
    tags = local.common_tags
}

# Create RDS MySQL instance
resource "aws_db_instance" "mysql" {
    identifier = "${var.project_name}-mysql"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    allocated_storage = 20
    username = var.db_username
    password = var.db_password
    db_name = var.db_name
    db_subnet_group_name = aws_db_subnet_group.db_subnets.name
    vpc_security_group_ids = [aws_security_group.db_sg.id]
    publicly_accessible = true
    skip_final_snapshot = true
    deletion_protection = false
    apply_immediately = true
    tags = local.common_tags
}

# Query AWS ami resource
data "aws_ami" "al2023" {
    owners = ["137112412989"]
    most_recent = true

    filter {
        name = "name"
        values = ["al2023-ami-*-x86_64"]
    }
}

# Create EC2 instance for Flask Backend
resource "aws_instance" "web" {
    ami = "ami-0f43441515b1d94b1"
    instance_type = var.instance_type
    subnet_id = data.aws_subnets.default.ids[0]
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    associate_public_ip_address = false

    key_name = "flights-booking-ec2"

    user_data = <<-EOF
        #!/bin/bash
        set -e
        yum update -y
        amazon-linux-extras enable Docker
        yum install -y docker git
        systemctl enable --now docker
        systemctl start docker 
        useradd -m deploy || true
        usermod -aG docker deploy
        echo "deploy ALL=(ALL) NOPASSWORD: /user/bin/docker" >> /etc/sudoers.d/deploy
    EOF

    tags = merge(local.common_tags, {Name = "${var.project_name}-web"})
}










