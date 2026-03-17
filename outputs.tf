output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "tzone_cms_complete_config" {
  description = "Complete CMS configuration for tzone-images"
  value = {
    bucket_name   = module.cms_images.bucket_name
    bucket_arn    = module.cms_images.bucket_arn
    region        = module.cms_images.region
    endpoint      = module.cms_images.s3_endpoint
    access_key_id = module.cms_images.cms_access_key_id
    secret_key    = module.cms_images.cms_secret_access_key
  }
  sensitive = true
}

output "cms_access_key_id" {
  description = "CMS Access Key ID"
  value       = module.cms_images.cms_access_key_id
  sensitive   = true
}

output "cms_secret_access_key" {
  description = "CMS Secret Access Key"
  value       = module.cms_images.cms_secret_access_key
  sensitive   = true
}


output "deploy_bucket_name" {
  description = "Name of the S3 deploy artifact bucket"
  value       = module.deploy_bucket.bucket_name
}

output "deploy_bucket_arn" {
  description = "ARN of the S3 deploy artifact bucket"
  value       = module.deploy_bucket.bucket_arn
}

output "github_actions_role_arn" {
  description = "IAM role ARN to set as AWS_DEPLOY_ROLE_ARN in GitHub Actions secrets"
  value       = module.deploy_iam.github_actions_role_arn
}

output "ec2_instance_profile_name" {
  description = "Instance profile name to attach to your EC2 launch template"
  value       = module.deploy_iam.ec2_instance_profile_name
}

output "ec2_instance_role_arn" {
  description = "ARN of the IAM role attached to EC2 instances"
  value       = module.deploy_iam.ec2_instance_role_arn
}
