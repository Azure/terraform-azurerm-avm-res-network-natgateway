<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-res-network-natgateway

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

## Resources

The following resources are used by this module:

- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) (resource)
- [azurerm_nat_gateway_public_ip_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) (resource)
- [azurerm_nat_gateway_public_ip_prefix_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_prefix_association) (resource)
- [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) (resource)
- [azurerm_public_ip_prefix.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_subnet_nat_gateway_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: (Required) Specifies the supported Azure location where the NAT Gateway should exist. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) Specifies the name of the NAT Gateway. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: (Required) Specifies the name of the Resource Group in which the NAT Gateway should exist. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_idle_timeout_in_minutes"></a> [idle\_timeout\_in\_minutes](#input\_idle\_timeout\_in\_minutes)

Description: (Optional) The idle timeout which should be used in minutes. Defaults to `4`.

Type: `number`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description:   Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_public_ip_configuration"></a> [public\_ip\_configuration](#input\_public\_ip\_configuration)

Description: This object describes the public IP configuration when creating Nat Gateway's with a public IP.  If creating more than one public IP, then these values will be used for all public IPs.

- `allocation_method`       = (Required) - Defines the allocation method for this IP address. Possible values are Static or Dynamic.
- `ddos_protection_mode`    = (Optional) - The DDoS protection mode of the public IP. Possible values are Disabled, Enabled, and VirtualNetworkInherited. Defaults to VirtualNetworkInherited.
- `ddos_protection_plan_id` = (Optional) - The ID of DDoS protection plan associated with the public IP. ddos\_protection\_plan\_id can only be set when ddos\_protection\_mode is Enabled
- `domain_name_label`       = (Optional) - Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system.
- `idle_timeout_in_minutes` = (Optional) - Specifies the timeout for the TCP idle connection. The value can be set between 4 and 30 minutes.
- `inherit_tags`            = (Optional) - Defaults to false.  Set this to false if only the tags defined on this resource should be applied. - Future functionality leaving in.
- `ip_version`              = (Optional) - The IP Version to use, IPv6 or IPv4. Changing this forces a new resource to be created. Only static IP address allocation is supported for IPv6.
- `lock_level`              = (Optional) - Set this value to override the resource level lock value.  Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `sku`                     = (Optional) - The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Standard to support zones by default. Changing this forces a new resource to be created. When sku\_tier is set to Global, sku must be set to Standard.
- `sku_tier`                = (Optional) - The SKU tier of the Public IP. Accepted values are Global and Regional. Defaults to Regional
- `tags`                    = (Optional) - A mapping of tags to assign to the resource.  
- `zones`                   = (Optional) - A list of zones where this public IP should be deployed. Defaults to 3 zones. If your region doesn't support zones, then you'll need to set this to null.  

  Example Inputs:

```hcl
#Standard Regional IPV4 Public IP address configuration
public_ip_configuration_details = {
  allocation_method       = "Static"
  ddos_protection_mode    = "VirtualNetworkInherited"
  idle_timeout_in_minutes = 30
  ip_version              = "IPv4"
  sku_tier                = "Regional"
  sku                     = "Standard"
}
```

Type:

```hcl
object({
    allocation_method       = optional(string, "Static")
    ddos_protection_mode    = optional(string, "VirtualNetworkInherited")
    ddos_protection_plan_id = optional(string)
    domain_name_label       = optional(string)
    idle_timeout_in_minutes = optional(number, 30)
    inherit_tags            = optional(bool, false)
    ip_version              = optional(string, "IPv4")
    lock_level              = optional(string, null)
    sku                     = optional(string, "Standard")
    sku_tier                = optional(string, "Regional")
    tags                    = optional(map(string), null)
    zones                   = optional(list(string), ["1", "2", "3"])
  })
```

Default:

```json
{
  "allocation_method": "Static",
  "ddos_protection_mode": "VirtualNetworkInherited",
  "idle_timeout_in_minutes": 30,
  "ip_version": "IPv4",
  "sku": "Standard",
  "sku_tier": "Regional",
  "zones": [
    "1",
    "2",
    "3"
  ]
}
```

### <a name="input_public_ip_prefix_length"></a> [public\_ip\_prefix\_length](#input\_public\_ip\_prefix\_length)

Description: (Optional) Public IP-prefix CIDR mask to use. Set to 0 to disable.

Type: `number`

Default: `0`

### <a name="input_public_ips"></a> [public\_ips](#input\_public\_ips)

Description: This map will define between 1 and 16 public IP's to assign to this NAT Gateway. The `public_ip_configuration` is used to configure common elements across all public IPs."

- `<map key>` - (Required) - The unique arbitrary map key is used by terraform to plan the number of public IP's to create
  - `name` - The name to use for this public IP resource

Example Input:

```hcl
public_ips = {
  ip_1 = {
    name = "nat_gw_pip_1"
  }
}
```

Type:

```hcl
map(object({
    name = string
  }))
```

Default: `{}`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description:   A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: (Optional) The SKU which should be used. At this time the only supported value is `Standard`. Defaults to `Standard`.

Type: `string`

Default: `null`

### <a name="input_subnet_associations"></a> [subnet\_associations](#input\_subnet\_associations)

Description: This map will define any subnet associations for this nat gateway. The

- `<map key>` - (Required) - The unique arbitrary map key is used by terraform to plan the number of subnet associations to create
  - `resource_id` - (Required) - The Azure Resource ID for the subnet to be associated to this NAT Gateway

Example Input:

```hcl
subnet_associations = {
  subnet_1 = {
    resource_id = azurerm_subnet.example.id
  }
}
```

Type:

```hcl
map(object({
    resource_id = string
    }
  ))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description: - `create` - (Defaults to 60 minutes) Used when creating the NAT Gateway.
- `delete` - (Defaults to 60 minutes) Used when deleting the NAT Gateway.
- `read` - (Defaults to 5 minutes) Used when retrieving the NAT Gateway.
- `update` - (Defaults to 60 minutes) Used when updating the NAT Gateway.

Type:

```hcl
object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
```

Default: `null`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: (Optional) A list of Availability Zones in which this NAT Gateway should be located. Changing this forces a new NAT Gateway to be created.

Type: `set(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_public_ip_prefix_value"></a> [public\_ip\_prefix\_value](#output\_public\_ip\_prefix\_value)

Description: The CIDR provisioned for the public IP prefix

### <a name="output_public_ip_resource"></a> [public\_ip\_resource](#output\_public\_ip\_resource)

Description: The public IP resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The NAT Gateway resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The ID of the NAT Gateway.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->