output "guardrail_arn" {
  description = "Amazon Resource Name (ARN) of the guardrail"
  value       = aws_bedrock_guardrail.main.guardrail_arn
}

output "guardrail_id" {
  description = "Unique identifier of the guardrail"
  value       = aws_bedrock_guardrail.main.guardrail_id
}

output "guardrail_name" {
  description = "Name of the guardrail"
  value       = aws_bedrock_guardrail.main.name
}

output "guardrail_status" {
  description = "Status of the guardrail"
  value       = aws_bedrock_guardrail.main.status
}

output "guardrail_created_at" {
  description = "Unix timestamp at which the guardrail was created"
  value       = aws_bedrock_guardrail.main.created_at
}

output "guardrail_updated_at" {
  description = "Unix timestamp at which the guardrail was updated"
  value       = aws_bedrock_guardrail.main.updated_at
}

output "guardrail_version" {
  description = "Version of the guardrail that was created"
  value       = aws_bedrock_guardrail.main.version
}

output "guardrail_version_arn" {
  description = "ARN of the guardrail version"
  value       = var.create_version ? aws_bedrock_guardrail_version.main[0].version_arn : null
}

output "guardrail_version_number" {
  description = "Version number of the guardrail version"
  value       = var.create_version ? aws_bedrock_guardrail_version.main[0].version : null
}