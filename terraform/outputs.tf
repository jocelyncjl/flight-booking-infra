output "frontend_bucket_name" {
    description = "S3 bucket name for hosting the frontend build artifacts"
    value = aws_s3_bucket.frontend.bucket
}

output "user_avatars_name" {
    description = "S3 bucket name for users account avatars"
    value = aws_s3_bucket.user_avatars.bucket
}

output "ec2_public_ip" {
    description = "Public IP of the EC2 instance hosting the Flask backend"
    value = aws_instance.web.public_ip
}


output "rds_mysql_endpoint" {
    description = "Endpoint of the RDS MySQl instance"
    value = aws_db_instance.mysql.address
}

output "rds_mysql_port" {
    description = "Port of the RDS MySQL instance" 
    value = aws_db_instance.mysql.port
}




