variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
}

variable "instance_type" {
  description = "Instance type for OpenSearch"
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of instances in the OpenSearch cluster"
  type        = number
  default     = 1
}