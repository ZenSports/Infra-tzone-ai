 output "bucket_name" {
   description = "S3 bucket name"
   value       = aws_s3_bucket.cms_images.bucket
 }
 output "bucket_arn" {
   description = "S3 bucket ARN"
   value       = aws_s3_bucket.cms_images.arn
 }
 output "region" {
   description = "AWS region"
   value       = var.region
 }
 output "cms_access_key_id" {
   description = "AWS Access Key ID for CMS"
   value       = aws_iam_access_key.cms_user_key.id
   sensitive   = true
 }
 output "cms_secret_access_key" {
   description = "AWS Secret Access Key for CMS"
   value       = aws_iam_access_key.cms_user_key.secret
   sensitive   = true
 }
 output "s3_endpoint" {
   description = "Public image URL endpoint"
   value       = "https://${aws_s3_bucket.cms_images.bucket}.s3.${var.region}.amazonaws.com"
 }
 output "cms_config" {
   description = "Complete CMS configuration"
   value = {
     bucket_name        = aws_s3_bucket.cms_images.bucket
     region             = var.region
     endpoint           = "https://${aws_s3_bucket.cms_images.bucket}.s3.${var.region}.amazonaws.com"
     access_key_id      = aws_iam_access_key.cms_user_key.id
     secret_access_key  = aws_iam_access_key.cms_user_key.secret
   }
 }
