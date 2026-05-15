<!-- -*- mode: markdown -*- -->

# terraform-null-label

See https://github.com/cloudposse/terraform-null-label

Supported styles (aka built-in presets with length, case, delimiter, etc):

* aws provider
  * aws (generic)
  * aws_s3_bucket
* confluent provider
  * confluent (generic)
  * confluent_connector
  * confluent_topic
* google provider
  * google (generic)
  * google_bigquery_dataset
  * google_bigquery_table
  * google_iam_role
  * google_iam_service_account
  * google_pubsub_subscription
  * google_pubsub_topic
  * google_secret_manager_secret
  * google_storage_bucket
  * google_storage_bucket_dns
* snowflake provider
  * snowflake (generic)
  * snowflake_database
  * snowflake_database_object
  * snowflake_schema
  * snowflake_schema_object
  * snowflake_space

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
---

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.7 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [random_id.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>  format = string<br/>  labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element.<br/>Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'" | `string` | `null` | no |
| <a name="input_id_hash_length"></a> [id\_hash\_length](#input\_id\_hash\_length) | Length of the hash to append to the `id` to ensure uniqueness.<br/>Set to `0` for no hash.<br/>Set to `null` for keep the existing setting, which defaults to `12`. | `number` | `null` | no |
| <a name="input_id_hash_unique"></a> [id\_hash\_unique](#input\_id\_hash\_unique) | Set to true to append a unique hash to the `id`, regardless of the `id_length_limit`. | `bool` | `null` | no |
| <a name="input_id_hash_version"></a> [id\_hash\_version](#input\_id\_hash\_version) | The version of the hash function to use.<br/><br/>Possible values:<br/>* `1` ~ cloudposse/terraform-null-label<br/>* `2` ~ cloudposse/label/null | `number` | `2` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element.<br/>Usually an abbreviation of your organization name, e.g. 'eg' or 'cp',<br/>to help ensure generated IDs are globally unique" | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_replacement"></a> [replacement](#input\_replacement) | Replacement string for the regex\_replace\_chars.<br/>Default is `""` (empty string). | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element.<br/>Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'" | `string` | `null` | no |
| <a name="input_style"></a> [style](#input\_style) | The naming style. Default is "aws".<br/><br/>Possible values:<br/>* `aws`<br/>* `aws_s3_bucket`<br/>* `confluent`<br/>* `confluent_connector`<br/>* `confluent_topic`<br/>* `google`<br/>* `google_bigquery_dataset`<br/>* `google_bigquery_table`<br/>* `google_iam_role`<br/>* `google_iam_service_account`<br/>* `google_pubsub_subscription`<br/>* `google_pubsub_topic`<br/>* `google_secret_manager_secret`<br/>* `google_storage_bucket`<br/>* `google_storage_bucket_dns`<br/>* `snowflake` ~ snowflake\_account\_object<br/>* `snowflake_database`<br/>* `snowflake_database_object`<br/>* `snowflake_schema`<br/>* `snowflake_schema_object`<br/>* `snowflake_space` | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_.<br/>A customer identifier, indicating who this instance of a resource is for" | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_additional_tag_map"></a> [additional\_tag\_map](#output\_additional\_tag\_map) | The merged additional\_tag\_map |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | List of attributes |
| <a name="output_context"></a> [context](#output\_context) | Merged but otherwise unmodified input to this module, to be used as context input to other modules.<br/>Note: this version will have null values as defaults, not the values actually used as defaults. |
| <a name="output_delimiter"></a> [delimiter](#output\_delimiter) | Delimiter between `namespace`, `tenant`, `environment`, `stage`, `name` and `attributes` |
| <a name="output_descriptors"></a> [descriptors](#output\_descriptors) | Map of descriptors as configured by `descriptor_formats` |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | True if module is enabled, false otherwise |
| <a name="output_environment"></a> [environment](#output\_environment) | Normalized environment |
| <a name="output_id"></a> [id](#output\_id) | Disambiguated ID string restricted to `id_length_limit` characters in total |
| <a name="output_id_full"></a> [id\_full](#output\_id\_full) | ID string not restricted in length |
| <a name="output_id_length_limit"></a> [id\_length\_limit](#output\_id\_length\_limit) | The id\_length\_limit actually used to create the ID, with `0` meaning unlimited |
| <a name="output_label_order"></a> [label\_order](#output\_label\_order) | The naming order actually used to create the ID |
| <a name="output_name"></a> [name](#output\_name) | Normalized name |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Normalized namespace |
| <a name="output_normalized_context"></a> [normalized\_context](#output\_normalized\_context) | Normalized context of this module |
| <a name="output_raw_context"></a> [raw\_context](#output\_raw\_context) | Unmodified input to this module, to be used as context input to other modules. |
| <a name="output_regex_replace_chars"></a> [regex\_replace\_chars](#output\_regex\_replace\_chars) | The regex\_replace\_chars actually used to create the ID |
| <a name="output_stage"></a> [stage](#output\_stage) | Normalized stage |
| <a name="output_tags"></a> [tags](#output\_tags) | Normalized Tag map |
| <a name="output_tags_as_list_of_maps"></a> [tags\_as\_list\_of\_maps](#output\_tags\_as\_list\_of\_maps) | This is a list with one map for each `tag`. Each map contains the tag `key`,<br/>`value`, and contents of `var.additional_tag_map`. Used in the rare cases<br/>where resources need additional configuration information for each tag. |
| <a name="output_tenant"></a> [tenant](#output\_tenant) | Normalized tenant |
<!-- END_TF_DOCS -->
<!-- markdownlint-enable -->
