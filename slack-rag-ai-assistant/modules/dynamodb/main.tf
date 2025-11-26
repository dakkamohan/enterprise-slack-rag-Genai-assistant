resource "aws_dynamodb_table" "chat_context" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "channel_id"
  range_key      = "timestamp"

  attribute {
    name = "channel_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name     = "user-index"
    hash_key = "user_id"
    range_key = "timestamp"
  }

  ttl {
    attribute_name = var.ttl_attribute
    enabled        = true
  }

  tags = {
    Name        = var.table_name
    Environment = "production"
    Purpose     = "slack-chatbot-context"
  }
}