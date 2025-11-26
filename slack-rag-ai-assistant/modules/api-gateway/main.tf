resource "aws_api_gateway_rest_api" "slack_bedrock_api" {
  name        = var.api_gateway_name
  description = "API Gateway for Slack Bedrock integration"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "*"
      }
    ]
  })
}

resource "aws_api_gateway_resource" "slack_events" {
  rest_api_id = aws_api_gateway_rest_api.slack_bedrock_api.id
  parent_id   = aws_api_gateway_rest_api.slack_bedrock_api.root_resource_id
  path_part   = "slack"
}

resource "aws_api_gateway_method" "slack_post" {
  rest_api_id   = aws_api_gateway_rest_api.slack_bedrock_api.id
  resource_id   = aws_api_gateway_resource.slack_events.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.slack_bedrock_api.id
  resource_id = aws_api_gateway_resource.slack_events.id
  http_method = aws_api_gateway_method.slack_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

resource "aws_api_gateway_method_response" "slack_post_200" {
  rest_api_id = aws_api_gateway_rest_api.slack_bedrock_api.id
  resource_id = aws_api_gateway_resource.slack_events.id
  http_method = aws_api_gateway_method.slack_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "slack_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.slack_bedrock_api.id
  resource_id = aws_api_gateway_resource.slack_events.id
  http_method = aws_api_gateway_method.slack_post.http_method
  status_code = aws_api_gateway_method_response.slack_post_200.status_code

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_api_gateway_deployment" "slack_bedrock_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration_response.slack_post_integration_response,
  ]

  rest_api_id = aws_api_gateway_rest_api.slack_bedrock_api.id
  stage_name  = "prod"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.slack_bedrock_api.execution_arn}/*/*"
}

data "aws_region" "current" {}