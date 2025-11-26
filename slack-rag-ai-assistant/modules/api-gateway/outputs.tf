output "api_gateway_url" {
  description = "API Gateway invoke URL"
  value       = "${aws_api_gateway_deployment.slack_bedrock_deployment.invoke_url}/slack"
}

output "api_gateway_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.slack_bedrock_api.id
}