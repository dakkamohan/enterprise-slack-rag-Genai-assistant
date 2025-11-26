variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "ttl_attribute" {
  description = "Name of the TTL attribute"
  type        = string
  default     = "expires_at"
}