# Archive Lambda Function
resource "aws_lambda_function" "archive_function" {
  filename         = "archive_lambda.zip"
  function_name    = "${var.function_name}-archive"
  role            = var.lambda_role_arn
  handler         = "archive_to_s3.lambda_handler"
  source_code_hash = data.archive_file.archive_lambda_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 900  # 15 minutes for large data sets

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      S3_BUCKET_NAME      = var.s3_bucket_name
    }
  }

  tags = {
    Name        = "${var.function_name}-archive"
    Environment = "production"
    Purpose     = "dynamodb-s3-archiving"
  }
}

# Package the archive Lambda code
data "archive_file" "archive_lambda_zip" {
  type        = "zip"
  source_file = "${var.source_code_path}/archive_to_s3.py"
  output_path = "archive_lambda.zip"
}

# EventBridge rule for daily archiving
resource "aws_cloudwatch_event_rule" "daily_archive" {
  name                = "${var.function_name}-daily-archive"
  description         = "Trigger archiving Lambda daily"
  schedule_expression = "cron(0 2 * * ? *)"  # Daily at 2 AM UTC

  tags = {
    Name        = "${var.function_name}-daily-archive"
    Environment = "production"
    Purpose     = "dynamodb-s3-archiving"
  }
}

# EventBridge target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_archive.name
  target_id = "ArchiveLambdaTarget"
  arn       = aws_lambda_function.archive_function.arn
}

# Lambda permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.archive_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_archive.arn
}