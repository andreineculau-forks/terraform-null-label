locals {
  # tflint-ignore: terraform_naming_convention
  _style = coalesce(var.style, local._defaults.style)
  # tflint-ignore: terraform_naming_convention
  _style_family = (
    local._style == "aws" || startswith(local._style, "aws_") ? "aws" :
    local._style == "confluent" || startswith(local._style, "confluent_") ? "confluent" :
    local._style == "google" || startswith(local._style, "google_") ? "google" :
    local._style == "snowflake" || startswith(local._style, "snowflake_") ? "snowflake" :
    "general"
  )
  # tflint-ignore: terraform_naming_convention
  _delimiter = (
    # Google exceptions
    local._style == "google_iam_role" ? "_" :
    # Snowflake exceptions
    local._style_family == "snowflake" ? coalesce(var.delimiter, "_") :
    # General
    coalesce(var.delimiter, "-")
  )

  # tflint-ignore: terraform_naming_convention
  _style_family_overrides = {
    google = {
      label_key_case = "lower"
    }
    snowflake = {
      delimiter        = "_"
      id_length_limit  = 255
      label_value_case = "upper"
    }
  }

  # tflint-ignore: terraform_naming_convention
  _style_overrides = {
    aws_s3_bucket = {
      id_length_limit = 255
    }
    confluent_connector = {
      id_length_limit     = 64
      regex_replace_chars = "/[^${local._delimiter}a-zA-Z0-9.,&_+|[]]/"
    }
    confluent_topic = {
      id_length_limit     = 255
      regex_replace_chars = "/[^${local._delimiter}a-zA-Z0-9_]/"
    }
    google_iam_role = {
      delimiter           = "_"
      regex_replace_chars = "/[^${local._delimiter}a-zA-Z0-9.]/"
      id_length_limit     = 64
      id_hash_unique      = true
    }
    google_iam_service_account = {
      id_length_limit = 30
    }
    google_storage_bucket = {
      id_length_limit = 63
    }
    google_storage_bucket_dns = {
      id_length_limit = 255
    }
    snowflake_database = {
      label_order = ["namespace", "tenant", "environment"]
    }
    snowflake_database_object = {
      label_order = ["name", "attributes"]
    }
    snowflake_schema = {
      label_order = ["stage"]
    }
    snowflake_schema_object = {
      label_order = ["name", "attributes"]
    }
    snowflake_space = {
      label_order = ["namespace", "tenant"]
    }
  }

  defaults = merge(
    local._defaults,
    {
      label_order         = ["namespace", "tenant", "environment", "stage", "name", "attributes"]
      delimiter           = local._delimiter
      regex_replace_chars = "/[^${local._delimiter}a-zA-Z0-9]/"
      id_length_limit     = 63
      id_hash_length      = 12 # mimic CloudFormation's hash length
      id_hash_unique      = false
      label_key_case      = "title"
      label_value_case    = "lower"
    },
    lookup(local._style_family_overrides, local._style_family, {}),
    lookup(local._style_overrides, local._style, {})
  )
}
