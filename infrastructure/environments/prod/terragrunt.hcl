# Configure Terragrunt to automatically store tfstate files in an S3 bucket, in appropriate paths
remote_state {
  backend = "s3"

  config = {
    bucket = "antoniocappiello-tf-remote-state"
    key = "terragrunt-demo/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "terraform-lock-table"
  }
}

include {
  path = find_in_parent_folders()
}

# Configure root level variables that all resources can inherit
inputs = {
  environment = "prod"
  bucket_prefix = ""

  remote_state_bucket_name = "antoniocappiello-tf-remote-state"

  base_tags = {
    "Environment" = "prod"
    "Customer" = "AntonioCappiello"
    "Ownership" = "terraform"
    "Service" = "Terragrunt Demo"
  }
}