resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.Network/natGateways@2025-03-01"
  body = {
    properties = {
      idleTimeoutInMinutes = var.idle_timeout_in_minutes
      publicIpAddresses = concat([
        for key, pip in azapi_resource.public_ip : {
          id = pip.id
        }
        if lower(try(var.public_ip_configuration[key].ip_version, local.default_pip_config.ip_version)) == "ipv4"
        ],
        [for id in var.public_ip_resource_ids : { id = id }]
      )
      publicIpAddressesV6 = concat([
        for key, pip in azapi_resource.public_ip : {
          id = pip.id
        }
        if lower(try(var.public_ip_configuration[key].ip_version, local.default_pip_config.ip_version)) == "ipv6"
        ],
        [for id in var.public_ip_v6_resource_ids : { id = id }]
      )
      publicIpPrefixes   = [for id in var.public_ip_prefix_resource_ids : { id = id }]
      publicIpPrefixesV6 = [for id in var.public_ip_prefix_v6_resource_ids : { id = id }]
    }
    sku = {
      name = var.sku_name
    }
    zones = var.sku_name == "StandardV2" ? ["1", "2", "3"] : var.zones
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    ignore_changes = [
      body.zones
    ]

    precondition {
      condition     = var.sku_name == "StandardV2" && length(var.public_ips) > 0 ? alltrue([for c in values(var.public_ip_configuration) : c.sku == "StandardV2"]) : true
      error_message = "When using StandardV2 SKU for NAT Gateway, all Public IP configurations must specify StandardV2 SKU."
    }
    precondition {
      condition     = var.sku_name == "Standard" && var.zones != null ? length(var.zones) <= 1 : true
      error_message = "Standard SKU NAT Gateway supports only a single zone (Zonal) or no zone (Regional)."
    }
  }
}

module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.5.0"

  diagnostic_settings_v2                    = var.diagnostic_settings
  enable_telemetry                          = var.enable_telemetry
  lock                                      = var.lock
  role_assignment_definition_lookup_enabled = true
  role_assignment_definition_scope          = "/subscriptions/${local.subscription_id}"
  role_assignments                          = var.role_assignments
}

resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name           = module.avm_interfaces.lock_azapi.name
  parent_id      = azapi_resource.this.id
  type           = module.avm_interfaces.lock_azapi.type
  body           = module.avm_interfaces.lock_azapi.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [
    azapi_resource.diagnostic_setting,
    azapi_resource.role_assignment,
  ]
}

resource "azapi_resource" "role_assignment" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name           = each.value.name
  parent_id      = azapi_resource.this.id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  # AVM requires retries for role assignments for improved reliability
  retry = {
    error_message_regex = ["PrincipalNotFound"]
  }
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "diagnostic_setting" {
  for_each = module.avm_interfaces.diagnostic_settings_azapi_v2

  name                 = each.value.name
  parent_id            = azapi_resource.this.id
  type                 = each.value.type
  body                 = each.value.body
  create_headers       = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers       = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_null_property = true
  read_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers       = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
