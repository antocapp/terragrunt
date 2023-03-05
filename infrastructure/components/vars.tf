variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
}

variable "environment" {
  description = "Environment; used for naming"
}

variable "remote_state_bucket_name" {
  description = "Remote state bucket name"
}