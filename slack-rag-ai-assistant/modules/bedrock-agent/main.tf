data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "bedrock_agent_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "bedrock_agent_role" {
  name               = "${var.agent_name}-agent-role"
  assume_role_policy = data.aws_iam_policy_document.bedrock_agent_assume_role.json
}

data "aws_iam_policy_document" "bedrock_agent_policy" {
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:GetFoundationModel",
      "bedrock:ListFoundationModels"
    ]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.foundation_model}"
    ]
  }

  dynamic "statement" {
    for_each = var.guardrail_configuration != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "bedrock:GetGuardrail",
        "bedrock:ApplyGuardrail"
      ]
      resources = [
        "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:guardrail/${var.guardrail_configuration.guardrail_identifier}"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.s3_bucket_name != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      resources = [
        "arn:aws:s3:::${var.s3_bucket_name}",
        "arn:aws:s3:::${var.s3_bucket_name}/*"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.enable_action_groups ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "lambda:InvokeFunction"
      ]
      resources = ["*"]
    }
  }
}

resource "aws_iam_policy" "bedrock_agent_policy" {
  name   = "${var.agent_name}-agent-policy"
  policy = data.aws_iam_policy_document.bedrock_agent_policy.json
}

resource "aws_iam_role_policy_attachment" "bedrock_agent_policy_attachment" {
  role       = aws_iam_role.bedrock_agent_role.name
  policy_arn = aws_iam_policy.bedrock_agent_policy.arn
}

resource "aws_s3_bucket" "knowledge_base" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_versioning" "knowledge_base_versioning" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.knowledge_base[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "knowledge_base_encryption" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.knowledge_base[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "knowledge_base_assume_role" {
  count = var.enable_knowledge_base ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "knowledge_base_role" {
  count              = var.enable_knowledge_base ? 1 : 0
  name               = "${var.agent_name}-kb-role"
  assume_role_policy = data.aws_iam_policy_document.knowledge_base_assume_role[0].json
}

data "aws_iam_policy_document" "knowledge_base_policy" {
  count = var.enable_knowledge_base ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:GetFoundationModel"
    ]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "aoss:APIAccessAll"
    ]
    resources = [
      aws_opensearchserverless_collection.knowledge_base[0].arn
    ]
  }
}

resource "aws_iam_policy" "knowledge_base_policy" {
  count  = var.enable_knowledge_base ? 1 : 0
  name   = "${var.agent_name}-kb-policy"
  policy = data.aws_iam_policy_document.knowledge_base_policy[0].json
}

resource "aws_iam_role_policy_attachment" "knowledge_base_policy_attachment" {
  count      = var.enable_knowledge_base ? 1 : 0
  role       = aws_iam_role.knowledge_base_role[0].name
  policy_arn = aws_iam_policy.knowledge_base_policy[0].arn
}

# OpenSearch Serverless Collection for Knowledge Base
resource "aws_opensearchserverless_collection" "knowledge_base" {
  count       = var.enable_knowledge_base ? 1 : 0
  name        = "${var.agent_name}-kb-collection"
  description = "OpenSearch collection for Bedrock knowledge base"
  type        = "VECTORSEARCH"
}

resource "aws_opensearchserverless_security_policy" "knowledge_base_encryption" {
  count       = var.enable_knowledge_base ? 1 : 0
  name        = "${var.agent_name}-kb-encryption-policy"
  type        = "encryption"
  description = "Encryption policy for knowledge base collection"
  policy = jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/${var.agent_name}-kb-collection"
          ]
          ResourceType = "collection"
        }
      ]
      AWSOwnedKey = true
    }
  ])
}

resource "aws_opensearchserverless_security_policy" "knowledge_base_network" {
  count       = var.enable_knowledge_base ? 1 : 0
  name        = "${var.agent_name}-kb-network-policy"
  type        = "network"
  description = "Network policy for knowledge base collection"
  policy = jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/${var.agent_name}-kb-collection"
          ]
          ResourceType = "collection"
        }
      ]
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_access_policy" "knowledge_base_data" {
  count       = var.enable_knowledge_base ? 1 : 0
  name        = "${var.agent_name}-kb-data-policy"
  type        = "data"
  description = "Data access policy for knowledge base collection"
  policy = jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/${var.agent_name}-kb-collection"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
          ResourceType = "collection"
        },
        {
          Resource = [
            "index/${var.agent_name}-kb-collection/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
          ResourceType = "index"
        }
      ]
      Principal = [
        aws_iam_role.knowledge_base_role[0].arn,
        data.aws_caller_identity.current.arn
      ]
    }
  ])
}

# Knowledge Base
resource "aws_bedrockagent_knowledge_base" "main" {
  count    = var.enable_knowledge_base ? 1 : 0
  name     = "${var.agent_name}-knowledge-base"
  role_arn = aws_iam_role.knowledge_base_role[0].arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model}"
    }
    type = "VECTOR"
  }

  storage_configuration {
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.knowledge_base[0].arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
    type = "OPENSEARCH_SERVERLESS"
  }

  depends_on = [
    aws_opensearchserverless_collection.knowledge_base,
    aws_opensearchserverless_access_policy.knowledge_base_data
  ]
}

resource "aws_bedrockagent_data_source" "main" {
  count               = var.enable_knowledge_base && var.s3_bucket_name != null ? 1 : 0
  knowledge_base_id   = aws_bedrockagent_knowledge_base.main[0].id
  name                = "${var.agent_name}-data-source"
  data_deletion_policy = "RETAIN"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.create_s3_bucket ? aws_s3_bucket.knowledge_base[0].arn : "arn:aws:s3:::${var.s3_bucket_name}"
      inclusion_prefixes = var.s3_inclusion_prefixes
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens     = var.chunk_max_tokens
        overlap_percentage = var.chunk_overlap_percentage
      }
    }
  }
}

resource "aws_bedrockagent_agent" "main" {
  agent_name                  = var.agent_name
  agent_resource_role_arn     = aws_iam_role.bedrock_agent_role.arn
  description                 = var.agent_description
  foundation_model            = var.foundation_model
  instruction                 = var.agent_instruction
  idle_session_ttl_in_seconds = var.idle_session_ttl
  prepare_agent               = var.prepare_agent

  dynamic "guardrail_configuration" {
    for_each = var.guardrail_configuration != null ? [var.guardrail_configuration] : []
    content {
      guardrail_identifier = guardrail_configuration.value.guardrail_identifier
      guardrail_version    = guardrail_configuration.value.guardrail_version
    }
  }

  dynamic "prompt_override_configuration" {
    for_each = var.enable_prompt_override ? [1] : []
    content {
      prompt_configurations {
        prompt_type    = "PRE_PROCESSING"
        prompt_state   = "ENABLED"
        prompt_creation_mode = "OVERRIDDEN"
        base_prompt_template = var.pre_processing_prompt
        inference_configuration {
          temperature = var.temperature
          top_p       = var.top_p
          top_k       = var.top_k
          maximum_length = var.max_tokens
          stop_sequences = var.stop_sequences
        }
      }
      prompt_configurations {
        prompt_type    = "ORCHESTRATION"
        prompt_state   = "ENABLED"
        prompt_creation_mode = "OVERRIDDEN"
        base_prompt_template = var.orchestration_prompt
        inference_configuration {
          temperature = var.temperature
          top_p       = var.top_p
          top_k       = var.top_k
          maximum_length = var.max_tokens
          stop_sequences = var.stop_sequences
        }
      }
      prompt_configurations {
        prompt_type    = "POST_PROCESSING"
        prompt_state   = "ENABLED"
        prompt_creation_mode = "OVERRIDDEN"
        base_prompt_template = var.post_processing_prompt
        inference_configuration {
          temperature = var.temperature
          top_p       = var.top_p
          top_k       = var.top_k
          maximum_length = var.max_tokens
          stop_sequences = var.stop_sequences
        }
      }
    }
  }

  depends_on = [aws_iam_role_policy_attachment.bedrock_agent_policy_attachment]
}

resource "aws_bedrockagent_agent_knowledge_base_association" "main" {
  count               = var.enable_knowledge_base ? 1 : 0
  agent_id            = aws_bedrockagent_agent.main.id
  description         = "Knowledge base association for ${var.agent_name}"
  knowledge_base_id   = aws_bedrockagent_knowledge_base.main[0].id
  knowledge_base_state = "ENABLED"
}

resource "aws_bedrockagent_agent_alias" "main" {
  agent_alias_name = var.agent_alias_name
  agent_id         = aws_bedrockagent_agent.main.id
  description      = var.agent_alias_description

  depends_on = [aws_bedrockagent_agent.main]
}