locals {
  # tflint-ignore: terraform_naming_convention
  _style = coalesce(var.style, local._defaults.style)
  # tflint-ignore: terraform_naming_convention
  _delimiter = (
    # Google exceptions
    local._style == "google_iam_role" ? "_" :
    # Snowflake exceptions
    local._style == "snowflake" || startswith(local._style, "snowflake_") ? coalesce(var.delimiter, "_") :
    # Fallback (default)
    coalesce(var.delimiter, "-")
  )
  # tflint-ignore: terraform_naming_convention
  _regex_replace_chars = (
    # Confluent exceptions
    local._style == "confluent_connector" ? "/[^${local._delimiter}a-zA-Z0-9.,&_+|[]]/" :
    local._style == "confluent_topic" ? "/[^${local._delimiter}a-zA-Z0-9_]/" :
    # Google exceptions
    local._style == "google_iam_role" ? "/[^${local._delimiter}a-zA-Z0-9.]/" :
    # Fallback (default)
    "/[^${local._delimiter}a-zA-Z0-9]/"
  )

  defaults = merge(
    local._defaults,
    {
      label_order = (
        # Snowflake exceptions
        local._style == "snowflake_database" ? ["namespace", "tenant", "environment"] :
        local._style == "snowflake_database_object" ? ["name", "attributes"] :
        local._style == "snowflake_schema" ? ["stage"] :
        local._style == "snowflake_schema_object" ? ["name", "attributes"] :
        local._style == "snowflake_space" ? ["namespace", "tenant"] :
        # Fallback (default plus tenant)
        ["namespace", "tenant", "environment", "stage", "name", "attributes"]
      )
      delimiter           = local._delimiter
      regex_replace_chars = local._regex_replace_chars
      id_length_limit = (
        # AWS exceptions
        local._style == "aws_s3_bucket" ? 255 :
        # Confluent exceptions
        local._style == "confluent_connector" ? 64 :
        local._style == "confluent_topic" ? 255 :
        # Google exceptions
        local._style == "google_storage_bucket" ? 63 :
        local._style == "google_iam_role" ? 64 :
        local._style == "google_iam_service_account" ? 30 :
        local._style == "google_storage_bucket_dns" ? 255 :
        # Snowflake
        local._style == "snowflake" || startswith(local._style, "snowflake_") ? 255 :
        # Fallback
        63
      )
      id_hash_length = 12 # mimic CloudFormation's hash length
      id_hash_unique = (
        # Google exceptions
        # see https://github.com/hashicorp/terraform-provider-google/issues/11311
        local._style == "google_iam_role" ? true :
        # Fallback (default)
        false
      )
      label_key_case = (
        # Google
        local._style == "google" || startswith(local._style, "google_") ? "lower" :
        # Fallback (default)
        "title"
      )
      label_value_case = (
        # Snowflake
        local._style == "snowflake" || startswith(local._style, "snowflake_") ? "upper" :
        # Fallback (default)
        "lower"
      )
    }
  )
}
