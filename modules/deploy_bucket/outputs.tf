output "bucket_name" {
  description = "Name of the deploy bucket"
  value       = aws_s3_bucket.deploy.bucket
}

output "bucket_arn" {
  description = "ARN of the deploy bucket"
  value       = aws_s3_bucket.deploy.arn
}
