variable "location" {
  type        = string
  description = "(Required) Specifies the supported Azure location where the NAT Gateway should exist. Changing this forces a new resource to be created."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) Specifies the name of the NAT Gateway. Changing this forces a new resource to be created."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Specifies the name of the Resource Group in which the NAT Gateway should exist. Changing this forces a new resource to be created."
  nullable    = false
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic settings.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`. For StandardV2, `NatGatewayFlowLogsV1` is available within `allLogs`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace Partner Logic App to send logs and metrics to.
DESCRIPTION
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "idle_timeout_in_minutes" {
  type        = number
  default     = null
  description = "(Optional) The idle timeout which should be used in minutes. Defaults to `4`."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:
  
  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "public_ip_configuration" {
  type = map(object({
    allocation_method       = optional(string, "Static")
    ddos_protection_mode    = optional(string, "VirtualNetworkInherited")
    ddos_protection_plan_id = optional(string)
    domain_name_label       = optional(string)
    idle_timeout_in_minutes = optional(number, 30)
    inherit_tags            = optional(bool, false)
    ip_version              = optional(string, "IPv4")
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    sku      = optional(string, "StandardV2")
    sku_tier = optional(string, "Regional")
    tags     = optional(map(string), null)
    zones    = optional(list(string), ["1", "2", "3"])
  }))
  default     = {}
  description = <<PUBLIC_IP_CONFIGURATION_DETAILS
This map describes the public IP configuration. Keys in this map should match keys in `public_ips` or `public_ip_prefixes`.

- `allocation_method`       = (Optional) - Defines the allocation method for this IP address. Possible values are Static or Dynamic. Defaults to Static.
- `ddos_protection_mode`    = (Optional) - The DDoS protection mode of the public IP. Possible values are Disabled, Enabled, and VirtualNetworkInherited. Defaults to VirtualNetworkInherited.
- `ddos_protection_plan_id` = (Optional) - The ID of DDoS protection plan associated with the public IP. ddos_protection_plan_id can only be set when ddos_protection_mode is Enabled
- `domain_name_label`       = (Optional) - Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system.
- `idle_timeout_in_minutes` = (Optional) - Specifies the timeout for the TCP idle connection. The value can be set between 4 and 30 minutes. Defaults to 30.
- `inherit_tags`            = (Optional) - Defaults to false.  Set this to false if only the tags defined on this resource should be applied.
- `ip_version`              = (Optional) - The IP Version to use, IPv6 or IPv4. Changing this forces a new resource to be created. Only static IP address allocation is supported for IPv6. Defaults to IPv4.
- `lock`                    = (Optional) - The lock level to apply to the public IP. Default is `null`.
- `sku`                     = (Optional) - The SKU of the Public IP. Accepted values are Basic, Standard and StandardV2. Defaults to StandardV2.
- `sku_tier`                = (Optional) - The SKU tier of the Public IP. Accepted values are Global and Regional. Defaults to Regional.
- `tags`                    = (Optional) - A mapping of tags to assign to the resource.    
- `zones`                   = (Optional) - A list of zones where this public IP should be deployed. Defaults to 3 zones.
  
  Example Input:

```hcl
public_ip_configuration = {
  ip_1 = {
    idle_timeout_in_minutes = 15
    sku                     = "StandardV2"
  },
  prefix_1 = {
    sku   = "StandardV2"
    zones = ["1", "2", "3"]
  }
}
```
PUBLIC_IP_CONFIGURATION_DETAILS
  nullable    = false
}

variable "public_ip_prefix_resource_ids" {
  type        = set(string)
  default     = []
  description = "(Optional) A list of existing Public IP Prefix resource IDs to associate with the NAT Gateway. These must be IPv4 prefixes."
  nullable    = false
}

variable "public_ip_prefix_v6_resource_ids" {
  type        = set(string)
  default     = []
  description = "(Optional) A list of existing Public IP Prefix resource IDs (IPv6) to associate with the NAT Gateway. Only supported when `sku_name` is `StandardV2`."
  nullable    = false
}

variable "public_ip_prefixes" {
  type = map(object({
    name          = string
    prefix_length = optional(number, 30)
  }))
  default     = {}
  description = <<PUBLIC_IP_PREFIXES
This map will define public IP prefixes.
- `<map key>` - The unique arbitrary map key.
  - `name` - The name to use for this public IP prefix resource.
  - `prefix_length` - (Optional) The Length of the Public IP Prefix. Defaults to 30.

  Example Input: 
```hcl
public_ip_prefixes = {
  prefix_1 = {
    name = "nat_gw_prefix_1"
    prefix_length = 31
  }
}
```
PUBLIC_IP_PREFIXES
}

variable "public_ip_resource_ids" {
  type        = set(string)
  default     = []
  description = "(Optional) A list of existing Public IP resource IDs to associate with the NAT Gateway. These must be IPv4 addresses."
  nullable    = false
}

variable "public_ip_v6_resource_ids" {
  type        = set(string)
  default     = []
  description = "(Optional) A list of existing Public IP resource IDs (IPv6) to associate with the NAT Gateway. Only supported when `sku_name` is `StandardV2`."
  nullable    = false
}

variable "public_ips" {
  type = map(object({
    name = string
  }))
  default     = {}
  description = <<PUBLIC_IPS
This map will define between 1 and 16 public IP's to assign to this NAT Gateway. The `public_ip_configuration` is used to configure common elements across all public IPs."

- `<map key>` - The unique arbitrary map key is used by terraform to plan the number of public IP's to create
  - `name` - The name to use for this public IP resource

Example Input: 

```hcl
public_ips = {
  ip_1 = {
    name = "nat_gw_pip_1"
  }
}
```
PUBLIC_IPS
}

variable "role_assignments" {
  type = map(object({
    role_definition_id                     = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
  - `role_definition_id` - The ID of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
  
  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

variable "sku_name" {
  type        = string
  default     = "StandardV2"
  description = "(Optional) The SKU which should be used. Possible values are `Standard` and `StandardV2`. Defaults to `StandardV2`."

  validation {
    condition     = contains(["Standard", "StandardV2"], var.sku_name == null ? "StandardV2" : var.sku_name)
    error_message = "The SKU name must be either `Standard` or `StandardV2`."
  }
}

variable "subnet_associations" {
  type = map(object({
    resource_id      = string
    address_prefix   = optional(string)
    address_prefixes = optional(list(string))
    ipam_pool_id     = optional(string)
  }))
  default     = {}
  description = <<SUBNET_ASSOCIATIONS
This map will define any subnet associations for this nat gateway. The 

- `<map key>` - The unique arbitrary map key is used by terraform to plan the number of subnet associations to create
  - `resource_id`      - The Azure Resource ID for the subnet to be associated to this NAT Gateway
  - `address_prefix`   - (Optional) The address prefix of the subnet. Required if `address_prefixes` or `ipam_pool_id` is not provided.
  - `address_prefixes` - (Optional) The address prefixes of the subnet. Required if `address_prefix` or `ipam_pool_id` is not provided.
  - `ipam_pool_id`     - (Optional) The IPAM pool ID of the subnet. Required if `address_prefix` or `address_prefixes` is not provided.

Example Input: 

```hcl
subnet_associations = {
  subnet_1 = {
    resource_id    = azurerm_subnet.example.id
    address_prefix = "10.0.1.0/24"
  }
  subnet_2 = {
    resource_id  = azurerm_subnet.example_ipam.id
    ipam_pool_id = "ipam-pool-id"
  }
}
```
SUBNET_ASSOCIATIONS

  validation {
    condition = alltrue([
      for k, v in var.subnet_associations :
      (v.ipam_pool_id != null) != (v.address_prefix != null || v.address_prefixes != null)
    ])
    error_message = "Each subnet association must specify either `ipam_pool_id` OR (`address_prefix` / `address_prefixes`), but not both."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 60 minutes) Used when creating the NAT Gateway.
 - `delete` - (Defaults to 60 minutes) Used when deleting the NAT Gateway.
 - `read` - (Defaults to 5 minutes) Used when retrieving the NAT Gateway.
 - `update` - (Defaults to 60 minutes) Used when updating the NAT Gateway.
EOT
}

variable "zones" {
  type        = set(string)
  default     = null
  description = "(Optional) A list of Availability Zones in which this NAT Gateway should be located. Changing this forces a new NAT Gateway to be created. If `sku_name` is `StandardV2`, this variable is ignored and defaults to `[\"1\", \"2\", \"3\"]`."
}
