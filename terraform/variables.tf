variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "project_name" {
    type = string
    default = "flight-booking"
}

variable "instance_type" {
    description = "EC2 instance type for the Flask backend"
    type = string
    default = "t3.micro"
}

variable "ssh_cidr" {
    description = "EC2 instance type for the Flask backend"
    type = string
    default = "0.0.0.0/0"
}

variable "flask_http_port" {
    description = "Port on which the Flask Docker container will listen"
    type = number
    default = 80
}

variable "db_username" {
    description = "Username for the RDS PostgreSQL instance"
    type = string
    default = "appuser"
}


variable "db_name" {
    description = "Database name for the RDS MySQL instance"
    type = string
    default = "flightdb"
}



