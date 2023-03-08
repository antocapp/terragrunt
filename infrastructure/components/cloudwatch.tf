resource "aws_lambda_permission" "demo_lambda_allow_cloudwatch" {
  count         = var.environment == "prod" ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatchLambdaDemo"
  action        = "lambda:InvokeFunction"
  function_name = module.demo_lambda.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_event_demo_lambda_trigger[0].arn
}

resource "aws_cloudwatch_event_rule" "scheduled_event_demo_lambda_trigger" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "DemoLambdaTrigger"
  description         = "Run demo lambda"
  schedule_expression = "cron(0 0 * * ? *)" #every day at midnight
  tags                = local.tags
  is_enabled          = var.environment == "prod"
}

resource "aws_cloudwatch_event_target" "scheduled_event_demo_lambda_trigger_product_one" {
  count     = var.environment == "prod" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.scheduled_event_demo_lambda_trigger[0].name
  target_id = "DemoLambdaProductId1"
  arn       = module.demo_lambda.lambda_function_arn
  input     = <<EOF
    {
      "id": 1
    }
EOF
}