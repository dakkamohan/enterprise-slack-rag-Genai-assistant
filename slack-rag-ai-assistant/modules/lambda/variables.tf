variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "source_code_path" {
  description = "Path to the Lambda function source code"
  type        = string
}

variable "bedrock_agent_id" {
  description = "Bedrock agent ID"
  type        = string
}

variable "bedrock_agent_alias" {
  description = "Bedrock agent alias"
  type        = string
}

variable "slack_signing_secret_arn" {
  description = "AWS Secrets Manager ARN for Slack app signing secret"
  type        = string
  sensitive   = true
}

variable "slack_bot_token_arn" {
  description = "AWS Secrets Manager ARN for Slack bot token"
  type        = string
  sensitive   = true
}

variable "slack_bot_user_id" {
  description = "Slack bot user ID for filtering bot mentions"
  type        = string
  default     = null
}

variable "guardrail_id" {
  description = "Bedrock guardrail ID"
  type        = string
  default     = null
}

variable "guardrail_version" {
  description = "Bedrock guardrail version"
  type        = string
  default     = null
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for context storage"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for long-term storage"
  type        = string
}

variable "opensearch_endpoint" {
  description = "OpenSearch domain endpoint for vector database"
  type        = string
}