variable "agent_name" {
  description = "Name of the Bedrock agent"
  type        = string
}

variable "agent_description" {
  description = "Description of the Bedrock agent"
  type        = string
  default     = "Bedrock agent for Slack integration"
}

variable "agent_instruction" {
  description = "Instructions for the Bedrock agent"
  type        = string
  default     = "You are a helpful AI assistant that responds to questions and provides information based on your knowledge and any available context."
}

variable "foundation_model" {
  description = "Foundation model for the Bedrock agent"
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "idle_session_ttl" {
  description = "Idle session TTL in seconds"
  type        = number
  default     = 3600
}

variable "prepare_agent" {
  description = "Whether to prepare the agent after creation"
  type        = bool
  default     = true
}

variable "agent_alias_name" {
  description = "Name of the agent alias"
  type        = string
  default     = "production"
}

variable "agent_alias_description" {
  description = "Description of the agent alias"
  type        = string
  default     = "Production alias for the Bedrock agent"
}

# Knowledge Base Configuration
variable "enable_knowledge_base" {
  description = "Enable knowledge base for the agent"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "S3 bucket name for knowledge base documents"
  type        = string
  default     = null
}

variable "create_s3_bucket" {
  description = "Create S3 bucket for knowledge base"
  type        = bool
  default     = false
}

variable "s3_inclusion_prefixes" {
  description = "S3 inclusion prefixes for data source"
  type        = list(string)
  default     = []
}

variable "embedding_model" {
  description = "Embedding model for knowledge base"
  type        = string
  default     = "amazon.titan-embed-text-v1"
}

variable "chunk_max_tokens" {
  description = "Maximum tokens per chunk"
  type        = number
  default     = 300
}

variable "chunk_overlap_percentage" {
  description = "Chunk overlap percentage"
  type        = number
  default     = 20
}

# Action Groups Configuration
variable "enable_action_groups" {
  description = "Enable action groups for the agent"
  type        = bool
  default     = false
}

# Prompt Override Configuration
variable "enable_prompt_override" {
  description = "Enable custom prompt templates"
  type        = bool
  default     = false
}

variable "pre_processing_prompt" {
  description = "Pre-processing prompt template"
  type        = string
  default     = ""
}

variable "orchestration_prompt" {
  description = "Orchestration prompt template"
  type        = string
  default     = ""
}

variable "post_processing_prompt" {
  description = "Post-processing prompt template"
  type        = string
  default     = ""
}

# Inference Configuration
variable "temperature" {
  description = "Temperature for model inference"
  type        = number
  default     = 0.7
}

variable "top_p" {
  description = "Top-p for model inference"
  type        = number
  default     = 0.9
}

variable "top_k" {
  description = "Top-k for model inference"
  type        = number
  default     = 250
}

variable "max_tokens" {
  description = "Maximum tokens for model response"
  type        = number
  default     = 2048
}

variable "stop_sequences" {
  description = "Stop sequences for model inference"
  type        = list(string)
  default     = []
}

# Guardrails Configuration
variable "guardrail_configuration" {
  description = "Guardrail configuration for the Bedrock agent"
  type = object({
    guardrail_identifier = string
    guardrail_version    = string
  })
  default = null
}