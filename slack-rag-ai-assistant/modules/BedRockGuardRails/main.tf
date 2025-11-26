resource "aws_bedrock_guardrail" "main" {
  name        = var.guardrail_name
  description = var.description

  blocked_input_messaging  = var.blocked_input_messaging
  blocked_outputs_messaging = var.blocked_outputs_messaging

  dynamic "content_policy_config" {
    for_each = var.content_policy_config != null ? [var.content_policy_config] : []
    content {
      dynamic "filters_config" {
        for_each = content_policy_config.value.filters_config
        content {
          input_strength  = filters_config.value.input_strength
          output_strength = filters_config.value.output_strength
          type           = filters_config.value.type
        }
      }
    }
  }

  dynamic "contextual_grounding_policy_config" {
    for_each = var.contextual_grounding_policy_config != null ? [var.contextual_grounding_policy_config] : []
    content {
      dynamic "filters_config" {
        for_each = contextual_grounding_policy_config.value.filters_config
        content {
          threshold = filters_config.value.threshold
          type      = filters_config.value.type
        }
      }
    }
  }

  dynamic "sensitive_information_policy_config" {
    for_each = var.sensitive_information_policy_config != null ? [var.sensitive_information_policy_config] : []
    content {
      dynamic "pii_entities_config" {
        for_each = sensitive_information_policy_config.value.pii_entities_config
        content {
          action = pii_entities_config.value.action
          type   = pii_entities_config.value.type
        }
      }

      dynamic "regexes_config" {
        for_each = sensitive_information_policy_config.value.regexes_config
        content {
          action      = regexes_config.value.action
          description = regexes_config.value.description
          name        = regexes_config.value.name
          pattern     = regexes_config.value.pattern
        }
      }
    }
  }

  dynamic "topic_policy_config" {
    for_each = var.topic_policy_config != null ? [var.topic_policy_config] : []
    content {
      dynamic "topics_config" {
        for_each = topic_policy_config.value.topics_config
        content {
          definition = topics_config.value.definition
          name       = topics_config.value.name
          type       = topics_config.value.type

          dynamic "examples" {
            for_each = topics_config.value.examples
            content {
              examples = examples.value
            }
          }
        }
      }
    }
  }

  dynamic "word_policy_config" {
    for_each = var.word_policy_config != null ? [var.word_policy_config] : []
    content {
      dynamic "managed_word_lists_config" {
        for_each = word_policy_config.value.managed_word_lists_config
        content {
          type = managed_word_lists_config.value.type
        }
      }

      dynamic "words_config" {
        for_each = word_policy_config.value.words_config
        content {
          text = words_config.value.text
        }
      }
    }
  }

  tags       = var.tags
}

resource "aws_bedrock_guardrail_version" "main" {
  count           = var.create_version ? 1 : 0
  guardrail_arn   = aws_bedrock_guardrail.main.guardrail_arn
  description     = var.version_description
  skip_destroy    = var.skip_destroy
}