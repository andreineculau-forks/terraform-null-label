# -*- mode: terraform -*-

override_resource {
  override_during = plan
  target          = random_id.main
  values = {
    id = "0val9ojw"
  }
}

variables {
  style = "google"
  name  = "test"
}

run "id_is_name" {
  command = plan
  assert {
    condition     = local.label_value_case == "lower"
    error_message = "unexpected case"
  }
  assert {
    condition     = local.id == "test"
    error_message = "unexpected transformations"
  }
}

run "id_is_namespace_tenant_environment_stage_name_attributes" {
  command = plan
  variables {
    namespace   = "namespace"
    tenant      = "tenant"
    environment = "environment"
    stage       = "stage"
    name        = "name"
    attributes  = ["attr1", "attr2"]
  }
  assert {
    condition     = local.delimiter == "-"
    error_message = "unexpected delimiter"
  }
  assert {
    condition     = local.id == "namespace-tenant-environment-stage-name-attr1-attr2"
    error_message = "unexpected transformations"
  }
}

run "id_truncates_name_to_63" {
  command = plan
  variables {
    # 65 characters
    name = "12345678901234567890123456789012345678901234567890123456789012345"
  }
  assert {
    condition     = local.id_length_limit == 63
    error_message = "id_length_limit should be 63 characters"
  }
  assert {
    condition     = length(local.id) == 63
    error_message = "id shouldn't be longer than 63 characters"
  }
  assert {
    condition     = local.id_hash_length == 12
    error_message = "id_hash_length should be 12 characters"
  }
  assert {
    condition     = substr(local.id, 0, 63 - 12 - 1) == substr(local.name, 0, 63 - 12 - 1)
    error_message = "id should match name, except for the hash and delimiter"
  }
}

run "tags_are_lower_case" {
  command = plan
  assert {
    condition     = local.label_key_case == "lower"
    error_message = "unexpected case"
  }
  assert {
    condition     = contains(keys(local.tags), "name")
    error_message = "unexpected case"
  }
}

run "google_iam_role" {
  command = plan
  variables {
    namespace   = "namespace"
    tenant      = "tenant"
    environment = "environment"
    stage       = "stage"
    name        = "name"
    attributes  = ["attr1"]
    style       = "google_iam_role"
  }
  assert {
    condition     = local.delimiter == "_"
    error_message = "unexpected delimiter"
  }
  assert {
    condition     = local.id_full == "namespace_tenant_environment_stage_name_attr1"
    error_message = "unexpected transformations"
  }
  assert {
    # NOTE 0f191ecb2cc31 is the md5 prefix of "${local.id_full}0val9ojw"
    condition     = local.id == "namespace_tenant_environment_stage_name_attr1_0f191ecb2cc31"
    error_message = "unexpected transformations"
  }
}

run "google_iam_role_length" {
  command = plan
  variables {
    namespace   = "namespace"
    tenant      = "tenant"
    environment = "environment"
    stage       = "stage"
    name        = "name"
    attributes  = ["attr1", "attr2", "attr3"]
    style       = "google_iam_role"
  }
  assert {
    condition     = local.delimiter == "_"
    error_message = "unexpected delimiter"
  }
  assert {
    condition     = local.id_full == "namespace_tenant_environment_stage_name_attr1_attr2_attr3"
    error_message = "unexpected transformations"
  }
  assert {
    # NOTE 96c73ff3fac9 is the md5 prefix of "${local.id_full}0val9ojw"
    # NOTE _attr3 is removed to fit the 64 character limit
    condition     = local.id == "namespace_tenant_environment_stage_name_attr1_attr2_96c73ff3fac9"
    error_message = "unexpected transformations"
  }
}

run "google_iam_service_account" {
  command = plan
  variables {
    namespace   = "namespace"
    tenant      = "tenant"
    environment = "environment"
    stage       = "stage"
    name        = "name"
    attributes  = ["attr1"]
    style       = "google_iam_service_account"
  }
  assert {
    condition     = local.id_length_limit == 30
    error_message = "id_length_limit should be 30 characters"
  }
  assert {
    condition     = length(local.id) == 30
    error_message = "id shouldn't be longer than 30 characters"
  }
  assert {
    condition     = local.id_hash_length == 12
    error_message = "id_hash_length should be 12 characters"
  }
  assert {
    condition     = local.id_full == "namespace-tenant-environment-stage-name-attr1"
    error_message = "unexpected transformations"
  }
  assert {
    condition     = local.id == "namespace-tenant-a6bf8a6ce12fe"
    error_message = "unexpected transformations"
  }
}

run "google_iam_service_account_length" {
  command = plan
  variables {
    # 65 characters
    name  = "12345678901234567890123456789012345678901234567890123456789012345"
    style = "google_iam_service_account"
  }
  assert {
    condition     = local.id_length_limit == 30
    error_message = "id_length_limit should be 30 characters"
  }
  assert {
    condition     = length(local.id) == 30
    error_message = "id shouldn't be longer than 30 characters"
  }
  assert {
    condition     = local.id_hash_length == 12
    error_message = "id_hash_length should be 12 characters"
  }
  assert {
    condition     = local.id_full == "12345678901234567890123456789012345678901234567890123456789012345"
    error_message = "unexpected transformations"
  }
  assert {
    condition     = local.id == "12345678901234567-823cc889fc73"
    error_message = "unexpected transformations"
  }
}

run "google_storage_bucket_dns" {
  command = plan
  variables {
    namespace   = "namespace.com"
    tenant      = "tenant"
    environment = "dev"
    stage       = "stage"
    name        = "name"
    attributes  = ["attr1"]
    style       = "google_storage_bucket_dns"
  }
  assert {
    condition     = local.label_order == ["tenant", "environment", "stage", "name", "attributes"]
    error_message = "unexpected label order"
  }
  assert {
    condition     = local.id_length_limit == 255
    error_message = "id_length_limit should be 255 characters"
  }
  assert {
    condition     = local.id_full == "tenant-dev-stage-name-attr1.namespace.com"
    error_message = "unexpected transformations"
  }
  assert {
    condition     = local.id == "tenant-dev-stage-name-attr1.namespace.com"
    error_message = "unexpected transformations"
  }
}

run "google_storage_bucket_dns_custom_label_order_dns" {
  command = plan
  variables {
    namespace       = "namespace.com"
    tenant          = "tenant"
    environment     = "dev"
    stage           = "stage"
    name            = "name"
    attributes      = ["attr1"]
    label_order_dns = ["environment", "tenant", "namespace"]
    style           = "google_storage_bucket_dns"
  }
  assert {
    condition     = local.label_order == ["stage", "name", "attributes"]
    error_message = "unexpected label order"
  }
  assert {
    condition     = local.label_order_dns == ["environment", "tenant", "namespace"]
    error_message = "unexpected DNS label order"
  }
  assert {
    condition     = local.id_full == "stage-name-attr1.dev.tenant.namespace.com"
    error_message = "unexpected transformations"
  }
  assert {
    condition     = local.id == "stage-name-attr1.dev.tenant.namespace.com"
    error_message = "unexpected transformations"
  }
}
