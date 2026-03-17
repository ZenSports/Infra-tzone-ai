terraform {
  backend "s3" {
    bucket  = "tzone-tfstate" # Your new bucket name
    key     = "global/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}