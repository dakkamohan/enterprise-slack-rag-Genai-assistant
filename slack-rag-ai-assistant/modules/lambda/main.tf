
data "aws_secretsmanager_secret_version" "slack_signing_secret" {
  secret_id = var.slack_signing_secret_arn
}

data "aws_secretsmanager_secret_version" "slack_bot_token" {
  secret_id = var.slack_bot_token_arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_code_path
  output_path = "${var.source_code_path}/lambda_function.zip"
}

resource "aws_lambda_function" "slack_bedrock_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role            = var.lambda_role_arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.11"
  timeout         = 60
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = merge(
      {
        BEDROCK_AGENT_ID         = var.bedrock_agent_id
        BEDROCK_AGENT_ALIAS      = var.bedrock_agent_alias
        SLACK_SIGNING_SECRET_ARN = var.slack_signing_secret_arn
        SLACK_BOT_TOKEN_ARN      = var.slack_bot_token_arn
        DYNAMODB_TABLE_NAME      = var.dynamodb_table_name
        S3_BUCKET_NAME           = var.s3_bucket_name
        OPENSEARCH_ENDPOINT      = var.opensearch_endpoint
      },
      var.slack_bot_user_id != null ? {
        SLACK_BOT_USER_ID = var.slack_bot_user_id
      } : {},
      var.guardrail_id != null ? {
        GUARDRAIL_ID      = var.guardrail_id
        GUARDRAIL_VERSION = var.guardrail_version
      } : {}
    )
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}