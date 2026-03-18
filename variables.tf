variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

//using odd Network bits for public and even for private to avoid confusion when looking at CIDRs in AWS console. Adjust as needed.
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}


//using odd Network bits for public and even for private to avoid confusion when looking at CIDRs in AWS console. Adjust as needed.
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ami_map" {
  description = "Map of AMI IDs for servers by name: api, backend, cms. Provide real shared AMI IDs via terraform.tfvars."
  type        = map(string)

  validation {
    condition     = alltrue([for required in ["api", "backend", "cms"] : contains(keys(var.ami_map), required)])
    error_message = "ami_map must contain keys: api, backend, cms"
  }
}

variable "ami_ids" {
  description = "List of AMI IDs for servers: api, backend, cms"
  type        = list(string)
  default     = ["ami-02db42145887042a4", "ami-0f11c38252b5b2ff9", "ami-0d0f88efc7838fc1d"]
}


variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.medium"
}

variable "cloudflare_ipv4" {
  description = "Cloudflare IPv4 ranges"
  type        = list(string)
  default = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.252.0/22"
  ]
}

variable "environment" {
  description = "Environment name (e.g. stage, prod)"
  type        = string
  default     = "stage"
}

variable "bucket_name" {
  description = "S3 bucket name for deploy artifacts"
  type        = string
  default     = "tzone-api-artifacts" # Change to a unique name
}

variable "artifact_retention_days" {
  description = "Days to retain deploy artifacts in S3 before auto-deletion"
  type        = number
  default     = 7
}

variable "github_org" {
  description = "GitHub organisation or user name (e.g. my-org)"
  type        = string
  default     = "ZenSports"
}

variable "github_repo" {
  description = "GitHub repository name (e.g. my-api-repo)"
  type        = string
  default     = "vip-play-orange-zone-api"
}

variable "github_branch" {
  description = "Branch that is allowed to assume the deploy role"
  type        = string
  default     = "*"
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group instances are deployed into"
  type        = string
  default     = "asg-api"
}

variable "github_environment" {
  description = "GitHub Actions environment name (e.g. stage, prod) - optional, used for additional scoping of deploy role"
  type        = string
  default     = "stage"
}

################################################################################
# DocumentDB
################################################################################

variable "docdb_cluster_identifier" {
  description = "Identifier for the DocumentDB cluster"
  type        = string
  default     = "vipplay-docdb"
}

variable "docdb_master_username" {
  description = "Master username for DocumentDB"
  type        = string
  default     = "dbadmin"
}

variable "docdb_master_password" {
  description = "Master password for DocumentDB"
  type        = string
  sensitive   = true
}

variable "docdb_instance_class" {
  description = "Instance class for DocumentDB"
  type        = string
  default     = "db.t3.medium"
}

variable "docdb_instance_count" {
  description = "Number of DocumentDB instances"
  type        = number
  default     = 1
}
