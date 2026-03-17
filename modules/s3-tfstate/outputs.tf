output "bucket_name" {
  description = "TF State bucket name"
  value       = aws_s3_bucket.tfstate.bucket
}

output "bucket_arn" {
  description = "TF State bucket ARN" 
  value       = aws_s3_bucket.tfstate.arn
}