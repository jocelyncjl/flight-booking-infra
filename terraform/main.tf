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

# Query Default VPC & Subnet

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

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "random_id" "suffix" {
    byte_length = 4
}

resource "aws_s3_bucket" "frontend" {
    bucket = "${var.project_name}-frontend-${random_id.suffix.hex}"
    tags = merge(local.common_tags, { Name = "${var.project_name}-frontend"})
}

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









