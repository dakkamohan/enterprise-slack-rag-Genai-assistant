output "domain_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = aws_opensearch_domain.vector_db.endpoint
}

output "domain_arn" {
  description = "OpenSearch domain ARN"
  value       = aws_opensearch_domain.vector_db.arn
}

output "kibana_endpoint" {
  description = "Kibana endpoint"
  value       = aws_opensearch_domain.vector_db.kibana_endpoint
}