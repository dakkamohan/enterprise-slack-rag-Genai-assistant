output "agent_id" {
  description = "ID of the Bedrock agent"
  value       = aws_bedrockagent_agent.main.id
}

output "agent_arn" {
  description = "ARN of the Bedrock agent"
  value       = aws_bedrockagent_agent.main.agent_arn
}

output "agent_name" {
  description = "Name of the Bedrock agent"
  value       = aws_bedrockagent_agent.main.agent_name
}

output "agent_alias_id" {
  description = "ID of the agent alias"
  value       = aws_bedrockagent_agent_alias.main.agent_alias_id
}

output "agent_alias_arn" {
  description = "ARN of the agent alias"
  value       = aws_bedrockagent_agent_alias.main.agent_alias_arn
}

output "agent_role_arn" {
  description = "ARN of the agent IAM role"
  value       = aws_iam_role.bedrock_agent_role.arn
}

output "knowledge_base_id" {
  description = "ID of the knowledge base"
  value       = var.enable_knowledge_base ? aws_bedrockagent_knowledge_base.main[0].id : null
}

output "knowledge_base_arn" {
  description = "ARN of the knowledge base"
  value       = var.enable_knowledge_base ? aws_bedrockagent_knowledge_base.main[0].knowledge_base_arn : null
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for knowledge base"
  value       = var.create_s3_bucket ? aws_s3_bucket.knowledge_base[0].id : var.s3_bucket_name
}

output "opensearch_collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = var.enable_knowledge_base ? aws_opensearchserverless_collection.knowledge_base[0].arn : null
}

output "opensearch_collection_endpoint" {
  description = "Endpoint of the OpenSearch Serverless collection"
  value       = var.enable_knowledge_base ? aws_opensearchserverless_collection.knowledge_base[0].collection_endpoint : null
}