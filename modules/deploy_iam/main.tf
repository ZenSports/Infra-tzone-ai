# -------------------------------------------------------
# GitHub Actions OIDC Provider
# Only created once per AWS account — use data source
# if it already exists in your account.
# -------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

# Check if OIDC provider already exists; import it if so.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]

  # GitHub's OIDC thumbprint — stable, updated by AWS automatically
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = var.tags
}

# -------------------------------------------------------
# GitHub Actions Deploy Role (assumed via OIDC)
# -------------------------------------------------------
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Scope to specific repo and branch — least privilege
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch == "*" ? "*" : var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.environment}-github-actions-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
  description        = "Assumed by GitHub Actions OIDC for ${var.github_repo} deploy"
  tags               = var.tags
}

data "aws_iam_policy_document" "github_actions_deploy" {
  # SSM — send commands and read results
  statement {
    sid    = "SSMSendCommand"
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations",
      "ssm:DescribeInstanceInformation",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}::document/AWS-RunShellScript",
    ]

    condition {
      test     = "StringEquals"
      variable = "ssm:ResourceTag/aws:autoscaling:groupName"
      values   = [var.asg_name]
    }
  }

  # SSM — wait/poll on command execution
  statement {
    sid    = "SSMWaitCommand"
    effect = "Allow"
    actions = [
      "ssm:GetCommandInvocation",
    ]
    resources = ["*"]
  }

  # ASG — discover InService instance IDs
  statement {
    sid    = "ASGDescribe"
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
    ]
    resources = ["*"]
  }

  # S3 — upload artifact and clean up
  statement {
    sid    = "S3DeployArtifacts"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObject",
    ]
    resources = ["${var.bucket_arn}/*"]
  }

  statement {
    sid    = "S3ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [var.bucket_arn]
  }
}

resource "aws_iam_policy" "github_actions_deploy" {
  name        = "${var.environment}-github-actions-deploy-policy"
  description = "Permissions for GitHub Actions to deploy via SSM to ${var.asg_name}"
  policy      = data.aws_iam_policy_document.github_actions_deploy.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}

# -------------------------------------------------------
# EC2 Instance Role (attached to ASG launch template)
# -------------------------------------------------------
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_instance" {
  name               = "${var.environment}-ec2-deploy-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  description        = "Role for EC2 instances in ${var.asg_name} - SSM and S3 deploy access"
  tags               = var.tags
}

# Core SSM connectivity — required for SSM agent to work
resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# S3 — pull deploy artifact
data "aws_iam_policy_document" "ec2_s3_deploy" {
  statement {
    sid    = "S3PullArtifact"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = ["${var.bucket_arn}/*"]
  }

  statement {
    sid    = "S3ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [var.bucket_arn]
  }
}

resource "aws_iam_policy" "ec2_s3_deploy" {
  name        = "${var.environment}-ec2-s3-deploy-policy"
  description = "Allows EC2 instances to pull deploy artifacts from S3"
  policy      = data.aws_iam_policy_document.ec2_s3_deploy.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_s3_deploy" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = aws_iam_policy.ec2_s3_deploy.arn
}

# Instance profile — what you attach to the launch template
resource "aws_iam_instance_profile" "ec2_instance" {
  name = "${var.environment}-ec2-deploy-instance-profile"
  role = aws_iam_role.ec2_instance.name
  tags = var.tags
}
