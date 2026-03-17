 variable "vpc_id" {
   description = "VPC ID"
   type        = string
 }
 variable "public_subnets" {
   description = "Public subnet IDs"
   type        = list(string)
 }
 variable "private_subnets" {
   description = "Private subnet IDs"
   type        = list(string)
 }
 variable "availability_zones" {
   description = "Availability zones"
   type        = list(string)
 }

 variable "ssl_certificate_arn" {
   description = "ARN of the SSL certificate in AWS Certificate Manager for the ALB"
   type        = string
   default = "arn:aws:acm:us-east-1:242873207908:certificate/817d6aa9-0e05-4dc3-9342-02149176af13"
 }  
 variable "ami_map" {
   description = "Map of AMI IDs keyed by server name (api, backend, cms)"
   type        = map(string)
 }
 variable "instance_type" {
   description = "Instance type for EC2"
   type        = string
 }
 variable "cloudflare_ipv4" {
   description = "Cloudflare IPv4 ranges"
   type        = list(string)
 }
 variable "rds_security_group_id" {
   description = "Security group ID for RDS access"
   type        = string
 }  