resource "aws_s3_bucket" "demo_lambda_functions" {
  bucket = "${var.bucket_prefix}antoniocappiello-demo-lambda-functions"
}