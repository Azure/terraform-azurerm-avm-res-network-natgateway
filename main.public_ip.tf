locals {
  default_pip_config = {
    allocation_method       = "Static"
    ddos_protection_mode    = "VirtualNetworkInherited"
    ddos_protection_plan_id = null
    domain_name_label       = null
    idle_timeout_in_minutes = 30
    inherit_tags            = false
    ip_version              = "IPv4"
    lock                    = null
    sku                     = "StandardV2"
    sku_tier                = "Regional"
    tags                    = null
    zones                   = ["1", "2", "3"]
  }
}

resource "azapi_resource" "public_ip" {
  for_each = var.public_ips

  location  = var.location
  name      = each.value.name
  parent_id = var.parent_id
  type      = "Microsoft.Network/publicIPAddresses@2025-03-01"
  body = {
    properties = {
      ddosSettings = try(var.public_ip_configuration[each.key].ddos_protection_mode, local.default_pip_config.ddos_protection_mode) == "Enabled" ? {
        ddosProtectionPlan = {
          id = try(var.public_ip_configuration[each.key].ddos_protection_plan_id, local.default_pip_config.ddos_protection_plan_id)
        }
        protectionMode = "Enabled"
        } : {
        ddosProtectionPlan = null
        protectionMode     = try(var.public_ip_configuration[each.key].ddos_protection_mode, local.default_pip_config.ddos_protection_mode)
      }
      dnsSettings = try(var.public_ip_configuration[each.key].domain_name_label, local.default_pip_config.domain_name_label) != null ? {
        domainNameLabel = try(var.public_ip_configuration[each.key].domain_name_label, local.default_pip_config.domain_name_label)
      } : null
      idleTimeoutInMinutes     = try(var.public_ip_configuration[each.key].idle_timeout_in_minutes, local.default_pip_config.idle_timeout_in_minutes)
      publicIPAddressVersion   = try(var.public_ip_configuration[each.key].ip_version, local.default_pip_config.ip_version)
      publicIPAllocationMethod = try(var.public_ip_configuration[each.key].allocation_method, local.default_pip_config.allocation_method)
    }
    sku = {
      name = try(var.public_ip_configuration[each.key].sku, local.default_pip_config.sku)
      tier = try(var.public_ip_configuration[each.key].sku_tier, local.default_pip_config.sku_tier)
    }
    zones = try(var.public_ip_configuration[each.key].zones, local.default_pip_config.zones)
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  tags           = try(var.public_ip_configuration[each.key].tags, local.default_pip_config.tags) != null ? try(var.public_ip_configuration[each.key].tags, local.default_pip_config.tags) : var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  lifecycle {
    ignore_changes = [body.zones]

    precondition {
      condition     = try(var.public_ip_configuration[each.key].sku, local.default_pip_config.sku) == "StandardV2" ? length(try(var.public_ip_configuration[each.key].zones, local.default_pip_config.zones)) == 3 : true
      error_message = "StandardV2 SKU must use all 3 zones."
    }
  }
}

resource "azapi_resource" "public_ip_lock" {
  for_each = {
    for k, v in var.public_ips : k => v
    if try(var.public_ip_configuration[k].lock, local.default_pip_config.lock) != null
  }

  name      = try(var.public_ip_configuration[each.key].lock.name, local.default_pip_config.lock.name) == null ? "lock-${try(var.public_ip_configuration[each.key].lock.kind, local.default_pip_config.lock.kind)}" : try(var.public_ip_configuration[each.key].lock.name, local.default_pip_config.lock.name)
  parent_id = azapi_resource.public_ip[each.key].id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = try(var.public_ip_configuration[each.key].lock.kind, local.default_pip_config.lock.kind)
      notes = try(var.public_ip_configuration[each.key].lock.kind, local.default_pip_config.lock.kind) == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}


