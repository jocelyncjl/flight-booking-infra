output "frontend_bucket_name" {
    description = "S3 bucket name for hosting the frontend build artifacts"
    value = aws_s3_bucket.frontend.bucket
}

