provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terraform-up-and-running-state-for-denizkin"
  # since deprecated
  # acl = "private" 
  
  #force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl_denizkin" {
  bucket = aws_s3_bucket.terraform_state_bucket.bucket
  acl    = "private"
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.terraform_state_bucket.bucket

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
    block_public_acls       = true
    block_public_policy     = true
    bucket                  = aws_s3_bucket.terraform_state_bucket.bucket
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "name" {
  bucket = aws_s3_bucket.terraform_state_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# Commenting this since this configuration is initialized in backend.hcl file
# USE THIS BEFORE TERRAGRUNT TO PUSH STATE FILE TO REMOTE S3 BUCKET!!!!!!!!
# terraform {
#   backend "s3" {
#     bucket = "terraform-up-and-running-state-for-denizkin"
#     key = "global/s3/terraform.tfstate"
#     region = "eu-central-1"
#     encrypt = true
   
#     dynamodb_table = "terraform-up-and-running-lock-for-denizkin"
#   }
# }

resource "aws_dynamodb_table" "GayDynamoDB" {
  name = "terraform-up-and-running-lock-for-denizkin"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  read_capacity  = 20
  write_capacity = 20

}
