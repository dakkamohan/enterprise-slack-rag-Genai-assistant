data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.lambda_function_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_bedrock_policy" {
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeAgent",
      "bedrock:GetAgent",
      "bedrock:ListAgents",
      "bedrock:InvokeModel",
      "bedrock:GetFoundationModel",
      "bedrock:ListFoundationModels"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "bedrock:GetGuardrail",
      "bedrock:ApplyGuardrail"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["arn:aws:secretsmanager:*:*:secret:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "es:ESHttpPost",
      "es:ESHttpPut",
      "es:ESHttpGet",
      "es:ESHttpDelete"
    ]
    resources = ["arn:aws:es:*:*:domain/*"]
  }
}

resource "aws_iam_policy" "lambda_bedrock_policy" {
  name        = "${var.lambda_function_name}-bedrock-policy"
  description = "IAM policy for Lambda to invoke Bedrock agents"
  policy      = data.aws_iam_policy_document.lambda_bedrock_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_bedrock_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_bedrock_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}