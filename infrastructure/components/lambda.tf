module "demo_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "4.1.3"

  function_name = "demo-lambda"
  description   = "Demo Lambda"

  recreate_missing_package          = false
  memory_size                       = 256 
  handler                           = "main.lambda_handler"
  runtime                           = "python3.9"
  publish                           = true
  timeout                           = 120
  lambda_role                       = aws_iam_role.demo_lambda.arn
  create_role                       = false
  cloudwatch_logs_retention_in_days = 7

  environment_variables = {
    "ENVIRONMENT"         = var.environment
  }

  #ARTIFACT STUFF
  create_package = true
  store_on_s3    = true
  s3_bucket      = aws_s3_bucket.demo_lambda_functions.id
  s3_prefix      = "demo-lambda/"

  source_path = [{
    path             = "/app/src/demo-lambda"
    pip_requirements = "/app/src/demo-lambda/requirements.txt"
    patterns = [
      "!tests/.*",
      "!__pycache__/.*",
    ]
  }]
}