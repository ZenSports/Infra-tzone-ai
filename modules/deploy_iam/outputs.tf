output "github_actions_role_arn" {
  description = "Role ARN to set as AWS_DEPLOY_ROLE_ARN in GitHub Actions secrets"
  value       = aws_iam_role.github_actions.arn
}

output "ec2_instance_role_arn" {
  description = "ARN of the EC2 instance role"
  value       = aws_iam_role.ec2_instance.arn
}

output "ec2_instance_profile_name" {
  description = "Instance profile name — attach this to your ASG launch template"
  value       = aws_iam_instance_profile.ec2_instance.name
}

output "ec2_instance_profile_arn" {
  description = "Instance profile ARN — use this if your launch template expects an ARN"
  value       = aws_iam_instance_profile.ec2_instance.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
