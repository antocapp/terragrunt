resource "aws_iam_role" "demo_lambda" {
  name               = "DemoLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.demo_lambda_assume_role.json
}

resource "aws_iam_role_policy" "demo_lambda_policy" {
  name   = "DemoLambdaPolicy"
  role   = aws_iam_role.demo_lambda.name
  policy = data.aws_iam_policy_document.demo_lambda_policy.json
}

data "aws_iam_policy_document" "demo_lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "demo_lambda_policy" {
  statement {
    effect = "Allow"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}