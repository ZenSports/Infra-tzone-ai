variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "tn-vols-infra"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = [ "10.0.2.0/24","10.0.4.0/24" ]
}

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

variable "cloudflare_ipv4" {
  description = "Cloudflare IPv4 ranges"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}