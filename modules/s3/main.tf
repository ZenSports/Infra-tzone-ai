 # S3 Bucket
 resource "aws_s3_bucket" "cms_images" {
   bucket = var.bucket_name
 }
 # Object Ownership
 resource "aws_s3_bucket_ownership_controls" "cms_images" {
   bucket = aws_s3_bucket.cms_images.id
   rule {
     object_ownership = "BucketOwnerEnforced"
   }
 }
 # Block Public Access (CMS safe)
 resource "aws_s3_bucket_public_access_block" "cms_images" {
   bucket = aws_s3_bucket.cms_images.id
 
   block_public_acls       = true
   ignore_public_acls      = true
   block_public_policy     = false
   restrict_public_buckets = false
 }
 # Public Read-Only Policy
 data "aws_iam_policy_document" "cms_images_public_read" {
   statement {
     sid    = "PublicReadGetObject"
     effect = "Allow"
   
     principals {
       type        = "*"
       identifiers = ["*"]
     }
   
     actions = ["s3:GetObject"]
     resources = ["${aws_s3_bucket.cms_images.arn}/*"]
   }
 }
 resource "aws_s3_bucket_server_side_encryption_configuration" "cms_images" {
   bucket = aws_s3_bucket.cms_images.id
 
   rule {
     apply_server_side_encryption_by_default {
       sse_algorithm = "AES256"  # Amazon S3 managed keys (free)
     }
   }
 }
 # ADD THESE - Versioning (recommended for CMS)
 resource "aws_s3_bucket_versioning" "cms_images" {
   bucket = aws_s3_bucket.cms_images.id
 
   versioning_configuration {
     status = "Disabled"
   }
 }
 resource "aws_s3_bucket_policy" "cms_images" {
   bucket = aws_s3_bucket.cms_images.id
   policy = data.aws_iam_policy_document.cms_images_public_read.json
 }
 # CMS IAM User
 resource "aws_iam_user" "cms_user" {
   name = "${var.bucket_name}-cms-user"
 }
 # CMS IAM Policy
 resource "aws_iam_user_policy" "cms_s3_policy" {
   name = "${var.bucket_name}-cms-policy"
   user = aws_iam_user.cms_user.name
   policy = jsonencode({
     Version = "2012-10-17"
     Statement = [
       {
         Effect = "Allow"
         Action = [
           "s3:PutObject",
           "s3:DeleteObject",
           "s3:ListBucket"
         ]
         Resource = [
           aws_s3_bucket.cms_images.arn,
           "${aws_s3_bucket.cms_images.arn}/*"
         ]
       }
     ]
   })
 }
 # Access Keys
 resource "aws_iam_access_key" "cms_user_key" {
   user = aws_iam_user.cms_user.name
 }