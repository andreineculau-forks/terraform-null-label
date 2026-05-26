# -*- mode: terraform -*-

variables {
  context = {
    namespace   = "namespace"
    tenant      = "tenant"
    environment = "environment"
    stage       = "stage"
    name        = "name"
    attributes  = ["attr1", "attr2"]
  }
  name = "test"
}

run "output" {
  command = plan
  assert {
    condition     = local.id == "namespace-tenant-environment-stage-test-attr1-attr2"
    error_message = "unexpected id"
  }
  assert { # outputs.context
    condition = jsonencode(local.input) == jsonencode({
      namespace   = "namespace"
      tenant      = "tenant"
      environment = "environment"
      stage       = "stage"
      name        = "test"
      attributes  = ["attr1", "attr2"],
      # defaults follow
      additional_tag_map  = {}
      delimiter           = null
      descriptor_formats  = {}
      label_order_dns     = null
      enabled             = true
      id_hash_length      = null
      id_hash_unique      = null
      id_hash_version     = 2
      id_length_limit     = null
      label_key_case      = null
      label_order         = []
      label_value_case    = null
      labels_as_tags      = ["default"]
      regex_replace_chars = null
      replacement         = null
      style               = null
      tags                = {}
    })
    error_message = "unexpected context: ${jsonencode(local.input)}"
  }
  assert { # outputs.normalized_context
    condition = jsonencode(local.output_context) == jsonencode({
      namespace   = "namespace"
      tenant      = "tenant"
      environment = "environment"
      stage       = "stage"
      name        = "test"
      attributes  = ["attr1", "attr2"]
      # defaults follow
      additional_tag_map  = {}
      delimiter           = "-"
      descriptor_formats  = {}
      label_order_dns     = []
      enabled             = true
      id_hash_length      = 12
      id_hash_unique      = false
      id_hash_version     = 2
      id_length_limit     = 63
      label_key_case      = "title"
      label_order         = ["namespace", "tenant", "environment", "stage", "name", "attributes"]
      label_value_case    = "lower"
      labels_as_tags      = ["attributes", "environment", "name", "namespace", "stage", "tenant"]
      regex_replace_chars = "/[^-a-zA-Z0-9]/"
      style               = "aws"
      tags = {
        Attributes  = "attr1-attr2"
        Environment = "environment"
        Name        = "namespace-tenant-environment-stage-test-attr1-attr2"
        Namespace   = "namespace"
        Stage       = "stage"
        Tenant      = "tenant"
      }
    })
    error_message = "unexpected normalized_context: ${jsonencode(local.output_context)}"
  }
}
