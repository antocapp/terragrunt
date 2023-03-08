resource "aws_s3_bucket" "demo_lambda_functions" {
  bucket = "demo-lambda-functions"
}

resource "aws_s3_bucket" "antoniocappiello_tf_remote_state" {
  bucket = "antoniocappiello-tf-remote-state"
}