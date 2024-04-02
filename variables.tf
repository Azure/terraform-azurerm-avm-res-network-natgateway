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

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
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

variable "public_ip_prefix_length" {
  type        = number
  default     = 0
  description = "(Optional) Public IP-prefix CIDR mask to use. Set to 0 to disable."

  validation {
    condition     = var.public_ip_prefix_length == 0 || var.public_ip_prefix_length >= 28 && var.public_ip_prefix_length <= 31
    error_message = "Invalid prefix size."
  }
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - The description of the role assignment.
  - `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - The condition which will be used to scope the role assignment.
  - `condition_version` - The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  
  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

variable "sku_name" {
  type        = string
  default     = null
  description = "(Optional) The SKU which should be used. At this time the only supported value is `Standard`. Defaults to `Standard`."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "(Optional) A mapping of tags to assign to the resource."
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
  description = "(Optional) A list of Availability Zones in which this NAT Gateway should be located. Changing this forces a new NAT Gateway to be created."
}
