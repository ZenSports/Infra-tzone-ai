variable "cluster_identifier" {
  description = "Identifier for the DocumentDB cluster"
  type        = string
  default     = "vipplay-docdb"
}

variable "vpc_id" {
  description = "VPC ID to deploy DocumentDB into"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the DocumentDB subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to DocumentDB (e.g. EC2 instances)"
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "DocumentDB engine version"
  type        = string
  default     = "5.0.0"
}

variable "parameter_group_family" {
  description = "DocumentDB parameter group family"
  type        = string
  default     = "docdb5.0"
}

variable "master_username" {
  description = "Master username for the DocumentDB cluster"
  type        = string
  default     = "dbadmin"
}

variable "master_password" {
  description = "Master password for the DocumentDB cluster"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for DocumentDB cluster instances"
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "Number of instances in the DocumentDB cluster"
  type        = number
  default     = 1
}

variable "storage_encrypted" {
  description = "Whether to encrypt DocumentDB storage at rest"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot on cluster deletion"
  type        = bool
  default     = true // true for dev/staging
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the cluster"
  type        = bool
  default     = false // false for dev/staging
}
