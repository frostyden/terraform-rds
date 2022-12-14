# Configure Terragrunt to automatically store tfstate files in S3
remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    encrypt        = true
    bucket         = "terraform-up-and-running-state-for-denizkin"
    key            = "prod/data-stores/mysql/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-up-and-running-lock-for-denizkin"

  }
}