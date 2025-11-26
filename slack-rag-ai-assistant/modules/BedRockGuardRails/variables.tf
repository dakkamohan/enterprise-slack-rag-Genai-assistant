variable "guardrail_name" {
  description = "The name of the guardrail"
  type        = string
}

variable "description" {
  description = "Description of the guardrail"
  type        = string
  default     = null
}

variable "blocked_input_messaging" {
  description = "Message to return when the guardrail blocks an input"
  type        = string
  default     = "I can't provide information on that topic."
}

variable "blocked_outputs_messaging" {
  description = "Message to return when the guardrail blocks a model response"
  type        = string
  default     = "I can't provide that information."
}

variable "content_policy_config" {
  description = "Content policy configuration for the guardrail"
  type = object({
    filters_config = list(object({
      input_strength  = string
      output_strength = string
      type           = string
    }))
  })
  default = null
}

variable "contextual_grounding_policy_config" {
  description = "Contextual grounding policy configuration for the guardrail"
  type = object({
    filters_config = list(object({
      threshold = number
      type      = string
    }))
  })
  default = null
}

variable "sensitive_information_policy_config" {
  description = "Sensitive information policy configuration for the guardrail"
  type = object({
    pii_entities_config = list(object({
      action = string
      type   = string
    }))
    regexes_config = list(object({
      action      = string
      description = string
      name        = string
      pattern     = string
    }))
  })
  default = null
}

variable "topic_policy_config" {
  description = "Topic policy configuration for the guardrail"
  type = object({
    topics_config = list(object({
      definition = string
      name       = string
      type       = string
      examples   = list(string)
    }))
  })
  default = null
}

variable "word_policy_config" {
  description = "Word policy configuration for the guardrail"
  type = object({
    managed_word_lists_config = list(object({
      type = string
    }))
    words_config = list(object({
      text = string
    }))
  })
  default = null
}


variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "create_version" {
  description = "Whether to create a version of the guardrail"
  type        = bool
  default     = false
}

variable "version_description" {
  description = "Description of the guardrail version"
  type        = string
  default     = null
}

variable "skip_destroy" {
  description = "Whether to skip destroying the guardrail version"
  type        = bool
  default     = false
}