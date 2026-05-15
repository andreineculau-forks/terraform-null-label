resource "random_id" "main" {
  for_each    = local.enabled && local.id_hash_unique ? { "enabled" : true } : {}
  byte_length = local.id_hash_length
}

locals {
  # tflint-ignore: terraform_naming_convention
  _defaults = {
    # The `tenant` label was introduced in v0.25.0. To preserve backward compatibility, or, really, to ensure
    # that people using the `tenant` label are alerted that it was not previously supported if they try to
    # use it in an older version, it is not included by default.
    label_order         = ["namespace", "environment", "stage", "name", "attributes"]
    regex_replace_chars = "/[^-a-zA-Z0-9]/"
    delimiter           = "-"
    replacement         = ""
    id_length_limit     = 0
    id_hash_length      = 5
    label_key_case      = "title"
    label_value_case    = "lower"
    style               = "default"
    id_hash_version     = 2

    # The default value of labels_as_tags cannot be included in this
    # defaults` map because it creates a circular dependency
  }

  default_labels_as_tags = keys(local.tags_context)
  # Unlike other inputs, the first setting of `labels_as_tags` cannot be later overridden. However,
  # we still have to pass the `input` map as the context to the next module. So we need to distinguish
  # between the first setting of var.labels_as_tags == null as meaning set the default and do not change
  # it later, versus later settings of var.labels_as_tags that should be ignored. So, we make the
  # default value in context be "unset", meaning it can be changed, but when it is unset and
  # var.labels_as_tags is null, we change it to "default". Once it is set to "default" we will
  # not allow it to be changed again, but of course we have to detect "default" and replace it
  # with local.default_labels_as_tags when we go to use it.
  #
  # We do not want to use null as default or unset, because Terraform has issues with
  # the value of an object field being null in some places and [] in others.
  # We do not want to use [] as default or unset because that is actually a valid setting
  # that we want to have override the default.
  #
  # To determine whether that context.labels_as_tags is not set,
  # we have to cover 2 cases: 1) context does not have a labels_as_tags key, 2) it is present and set to ["unset"]
  context_labels_as_tags_is_unset = try(contains(local.raw_input.labels_as_tags, "unset"), true)

  raw_input = merge(
    {
      enabled             = true
      namespace           = null
      tenant              = null
      environment         = null
      stage               = null
      name                = null
      delimiter           = null
      attributes          = []
      tags                = {}
      additional_tag_map  = {}
      regex_replace_chars = null
      label_order         = []
      replacement         = null
      id_length_limit     = null
      id_hash_length      = null
      id_hash_unique      = null
      label_key_case      = null
      label_value_case    = null
      descriptor_formats  = {}
      # Note: we have to use [] instead of null for unset lists due to
      # https://github.com/hashicorp/terraform/issues/28137
      # which was not fixed until Terraform 1.0.0,
      # but we want the default to be all the labels in `label_order`
      # and we want users to be able to prevent all tag generation
      # by setting `labels_as_tags` to `[]`, so we need
      # a different sentinel to indicate "default"
      labels_as_tags  = ["unset"]
      style           = null
      id_hash_version = null
    },
    var.context
  )

  # The values provided by variables supersede the values inherited from the context object,
  # except for tags and attributes which are merged.
  input = {
    # It would be nice to use coalesce here, but we cannot, because it
    # is an error for all the arguments to coalesce to be empty.
    enabled   = try(coalesce(var.enabled, local.raw_input.enabled), true)
    namespace = try(coalesce(var.namespace, local.raw_input.namespace), null)
    # tenant was introduced in v0.25.0, prior context versions do not have it
    tenant      = try(coalesce(var.tenant, local.raw_input.tenant), null)
    environment = try(coalesce(var.environment, local.raw_input.environment), null)
    stage       = try(coalesce(var.stage, local.raw_input.stage), null)
    name        = try(coalesce(var.name, local.raw_input.name), null)
    delimiter   = try(coalesce(var.delimiter, local.raw_input.delimiter), null)
    # modules tack on attributes (passed by var) to the end of the list (passed by context)
    attributes = compact(distinct(concat(local.raw_input.attributes, var.attributes)))
    tags       = merge(local.raw_input.tags, var.tags)

    additional_tag_map  = merge(local.raw_input.additional_tag_map, var.additional_tag_map)
    label_order         = try(coalesce(var.label_order, local.raw_input.label_order), [])
    regex_replace_chars = try(coalesce(var.regex_replace_chars, local.raw_input.regex_replace_chars), null)
    replacement         = try(coalesce(var.replacement, local.raw_input.replacement), null)
    id_length_limit     = try(coalesce(var.id_length_limit, local.raw_input.id_length_limit), null)
    id_hash_length      = try(coalesce(var.id_hash_length, local.raw_input.id_hash_length), null)
    id_hash_unique      = try(coalesce(var.id_hash_unique, local.raw_input.id_hash_unique), null)
    label_key_case      = try(coalesce(var.label_key_case, local.raw_input.label_key_case), null)
    label_value_case    = try(coalesce(var.label_value_case, local.raw_input.label_value_case), null)

    descriptor_formats = merge(local.raw_input.descriptor_formats, var.descriptor_formats)
    labels_as_tags = (
      local.context_labels_as_tags_is_unset ? var.labels_as_tags :
      try(local.raw_input.labels_as_tags, ["default"])
    )

    style           = try(coalesce(var.style, local.raw_input.style), null)
    id_hash_version = try(coalesce(var.id_hash_version, local.raw_input.id_hash_version), null)
  }


  enabled             = local.input.enabled
  regex_replace_chars = coalesce(local.input.regex_replace_chars, local.defaults.regex_replace_chars)

  # string_label_names are names of inputs that are strings (not list of strings) used as labels
  string_label_names = ["namespace", "tenant", "environment", "stage", "name"]
  normalized_labels = { for k in local.string_label_names : k =>
    local.input[k] == null ? "" :
    replace(local.input[k], local.regex_replace_chars, local.replacement)
  }
  normalized_attributes = compact(distinct(
    [for v in local.input.attributes : replace(v, local.regex_replace_chars, local.replacement)]
  ))

  formatted_labels = {
    for k in local.string_label_names : k =>
    local.label_value_case == "none" ? local.normalized_labels[k] :
    local.label_value_case == "title" ? title(lower(local.normalized_labels[k])) :
    local.label_value_case == "upper" ? upper(local.normalized_labels[k]) :
    lower(local.normalized_labels[k])
  }

  attributes = compact(distinct([
    for v in local.normalized_attributes : (local.label_value_case == "none" ? v :
      local.label_value_case == "title" ? title(lower(v)) :
    local.label_value_case == "upper" ? upper(v) : lower(v))
  ]))

  namespace   = local.formatted_labels["namespace"]
  tenant      = local.formatted_labels["tenant"]
  environment = local.formatted_labels["environment"]
  stage       = local.formatted_labels["stage"]
  name        = local.formatted_labels["name"]

  delimiter        = coalesce(local.input.delimiter, local.defaults.delimiter)
  label_order      = coalescelist(coalesce(local.input.label_order, []), local.defaults.label_order)
  replacement      = try(coalesce(local.input.replacement, local.defaults.replacement), local.defaults.replacement)
  id_length_limit  = coalesce(local.input.id_length_limit, local.defaults.id_length_limit)
  id_hash_length   = coalesce(local.input.id_hash_length, local.defaults.id_hash_length)
  id_hash_unique   = coalesce(local.input.id_hash_unique, local.defaults.id_hash_unique)
  label_key_case   = coalesce(local.input.label_key_case, local.defaults.label_key_case)
  label_value_case = coalesce(local.input.label_value_case, local.defaults.label_value_case)

  # labels_as_tags is an exception to the rule that input vars override context values (see above)
  labels_as_tags = (
    contains(local.input.labels_as_tags, "default") ? local.default_labels_as_tags :
    local.input.labels_as_tags
  )

  style           = coalesce(local.input.style, local.defaults.style)
  id_hash_version = coalesce(local.input.id_hash_version, local.defaults.id_hash_version)

  # Just for standardization and completeness
  descriptor_formats = local.input.descriptor_formats

  additional_tag_map = local.input.additional_tag_map

  tags = merge(local.generated_tags, local.input.tags)

  tags_as_list_of_maps = flatten([
    for key in keys(local.tags) : merge(
      {
        key   = key
        value = local.tags[key]
    }, local.additional_tag_map)
  ])

  tags_context = {
    namespace   = local.namespace
    tenant      = local.tenant
    environment = local.environment
    stage       = local.stage
    # For AWS we need `Name` to be disambiguated since it has a special meaning
    name       = local._style == "aws" || startswith(local._style, "aws_") ? local.id : local.name
    attributes = local.id_context.attributes
  }

  generated_tags = {
    for l in setintersection(keys(local.tags_context), local.labels_as_tags) :
    local.label_key_case == "upper" ? upper(l) : (
      local.label_key_case == "lower" ? lower(l) : title(lower(l))
    ) => local.tags_context[l] if length(local.tags_context[l]) > 0
  }

  id_context = {
    namespace   = local.namespace
    tenant      = local.tenant
    environment = local.environment
    stage       = local.stage
    name        = local.name
    attributes  = join(local.delimiter, local.attributes)
  }

  labels = [for l in local.label_order : local.id_context[l] if length(local.id_context[l]) > 0]

  id_full = join(local.delimiter, local.labels)
  # Create a truncated ID if needed
  delimiter_length = length(local.delimiter)
  # Calculate length of normal part of ID, leaving room for delimiter and hash
  id_truncated_length_limit = local.id_length_limit - (local.id_hash_length + local.delimiter_length)
  # Truncate the ID and ensure a single (not double) trailing delimiter
  id_truncated = (
    local.id_truncated_length_limit <= 0 ? "" :
    "${trimsuffix(substr(local.id_full, 0, local.id_truncated_length_limit), local.delimiter)}${local.delimiter}"
  )
  # Support usages that disallow numeric characters. Similar to tr 0-9 q-z.
  id_hash_plus_neg_v1 = "qrstuvwxyz"
  id_hash_plus_neg_v2 = (
    replace(
      replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(
                      replace(
                        md5("${local.id_full}${try(random_id.main["enabled"].id, "")}"),
                      "0", "q"),
                    "1", "r"),
                  "2", "s"),
                "3", "t"),
              "4", "u"),
            "5", "v"),
          "6", "w"),
        "7", "x"),
      "8", "y"),
    "9", "z")
  )
  id_hash_plus = (
    local.id_hash_version == 1 ? "${md5(local.id_full)}${local.id_hash_plus_neg_v1}" :
    "${md5("${local.id_full}${try(random_id.main["enabled"].id, "")}")}${local.id_hash_plus_neg_v2}"
  )
  id_hash_case = (
    local.label_value_case == "title" ? title(local.id_hash_plus) :
    local.label_value_case == "upper" ? upper(local.id_hash_plus) :
    local.label_value_case == "lower" ? lower(local.id_hash_plus) :
    local.id_hash_plus
  )
  id_hash = substr(replace(local.id_hash_case, local.regex_replace_chars, local.replacement), 0, local.id_hash_length + local.delimiter_length) # editorconfig-checker-disable-line
  # Create the short ID by adding a hash to the end of the truncated ID
  id_short = substr("${local.id_truncated}${local.id_hash}", 0, local.id_length_limit)
  id = (
    local.id_hash_unique ? local.id_short :
    local.id_length_limit != 0 && length(local.id_full) > local.id_length_limit ? local.id_short :
    local.id_full
  )


  # Context of this label to pass to other label modules
  output_context = {
    enabled             = local.enabled
    namespace           = local.namespace
    tenant              = local.tenant
    environment         = local.environment
    stage               = local.stage
    name                = local.name
    delimiter           = local.delimiter
    attributes          = local.attributes
    tags                = local.tags
    additional_tag_map  = local.additional_tag_map
    label_order         = local.label_order
    regex_replace_chars = local.regex_replace_chars
    id_length_limit     = local.id_length_limit
    label_key_case      = local.label_key_case
    label_value_case    = local.label_value_case
    labels_as_tags      = local.labels_as_tags
    descriptor_formats  = local.descriptor_formats
    style               = local.style
    id_hash_length      = local.id_hash_length
    id_hash_unique      = local.id_hash_unique
    id_hash_version     = local.id_hash_version
  }

}
