<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Create the following environment secrets on the `test` environment:
   1. AZURE\_CLIENT\_ID
   1. AZURE\_TENANT\_ID
   1. AZURE\_SUBSCRIPTION\_ID

<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.71.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.71.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_nat_gateway_location"></a> [nat\_gateway\_location](#input\_nat\_gateway\_location) | (Required) Specifies the supported Azure location where the NAT Gateway should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_nat_gateway_name"></a> [nat\_gateway\_name](#input\_nat\_gateway\_name) | (Required) Specifies the name of the NAT Gateway. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_nat_gateway_resource_group_name"></a> [nat\_gateway\_resource\_group\_name](#input\_nat\_gateway\_resource\_group\_name) | (Required) Specifies the name of the Resource Group in which the NAT Gateway should exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br><br>- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.<br>- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.<br>- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.<br>- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.<br>- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.<br>- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.<br>- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.<br>- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.<br>- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.<br>- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs. | <pre>map(object({<br>    name                                     = optional(string, null)<br>    log_categories                           = optional(set(string), [])<br>    log_groups                               = optional(set(string), ["allLogs"])<br>    metric_categories                        = optional(set(string), ["AllMetrics"])<br>    log_analytics_destination_type           = optional(string, "Dedicated")<br>    workspace_resource_id                    = optional(string, null)<br>    storage_account_resource_id              = optional(string, null)<br>    event_hub_authorization_rule_resource_id = optional(string, null)<br>    event_hub_name                           = optional(string, null)<br>    marketplace_partner_resource_id          = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | This variable controls whether or not telemetry is enabled for the module.<br>For more information see https://aka.ms/avm/telemetryinfo.<br>If it is set to false, then no telemetry will be collected. | `bool` | `true` | no |
| <a name="input_lock"></a> [lock](#input\_lock) | The lock level to apply to the Key Vault. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`. | <pre>object({<br>    name = optional(string, null)<br>    kind = optional(string, "None")<br>  })</pre> | `{}` | no |
| <a name="input_nat_gateway_idle_timeout_in_minutes"></a> [nat\_gateway\_idle\_timeout\_in\_minutes](#input\_nat\_gateway\_idle\_timeout\_in\_minutes) | (Optional) The idle timeout which should be used in minutes. Defaults to `4`. | `number` | `null` | no |
| <a name="input_nat_gateway_sku_name"></a> [nat\_gateway\_sku\_name](#input\_nat\_gateway\_sku\_name) | (Optional) The SKU which should be used. At this time the only supported value is `Standard`. Defaults to `Standard`. | `string` | `null` | no |
| <a name="input_nat_gateway_tags"></a> [nat\_gateway\_tags](#input\_nat\_gateway\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_nat_gateway_timeouts"></a> [nat\_gateway\_timeouts](#input\_nat\_gateway\_timeouts) | - `create` - (Defaults to 60 minutes) Used when creating the NAT Gateway.<br>- `delete` - (Defaults to 60 minutes) Used when deleting the NAT Gateway.<br>- `read` - (Defaults to 5 minutes) Used when retrieving the NAT Gateway.<br>- `update` - (Defaults to 60 minutes) Used when updating the NAT Gateway. | <pre>object({<br>    create = optional(string)<br>    delete = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_nat_gateway_zones"></a> [nat\_gateway\_zones](#input\_nat\_gateway\_zones) | (Optional) A list of Availability Zones in which this NAT Gateway should be located. Changing this forces a new NAT Gateway to be created. | `set(string)` | `null` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of role assignments to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.<br><br>- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.<br>- `principal_id` - The ID of the principal to assign the role to.<br>- `description` - The description of the role assignment.<br>- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.<br>- `condition` - The condition which will be used to scope the role assignment.<br>- `condition_version` - The version of the condition syntax. If you are using a condition, valid values are '2.0'.<br><br>> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal. | <pre>map(object({<br>    role_definition_id_or_name             = string<br>    principal_id                           = string<br>    description                            = optional(string, null)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>    condition                              = optional(string, null)<br>    condition_version                      = optional(string, null)<br>    delegated_managed_identity_resource_id = optional(string, null)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource"></a> [resource](#output\_resource) | The NAT Gateway resource. |

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->