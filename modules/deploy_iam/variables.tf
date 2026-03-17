variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 deploy artifact bucket"
  type        = string
}

variable "github_org" {
  description = "GitHub organisation or user name"
  type        = string
  default = "ZenSports"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default = "vip-play-orange-zone-api"
}

variable "github_branch" {
  description = "Branch allowed to assume the deploy role"
  type        = string
  default     = "stage"
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group — used to scope SSM SendCommand"
  type        = string
  default     = "asg-api"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    "Project"     = "TzoneAI",
    "Environment" = "stage"
  }
}
