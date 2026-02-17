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

resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "random_uuid" "role_assignment_name" {
  for_each = var.role_assignments
}

resource "azapi_resource" "role_assignment" {
  for_each = var.role_assignments

  name      = random_uuid.role_assignment_name[each.key].result
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      roleDefinitionId                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : "/subscriptions/${local.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${each.value.role_definition_id_or_name}"
      principalId                        = each.value.principal_id
      principalType                      = each.value.principal_type
      description                        = each.value.description
      condition                          = each.value.condition
      conditionVersion                   = each.value.condition_version
      delegatedManagedIdentityResourceId = each.value.delegated_managed_identity_resource_id
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  # AVM requires retries for role assignments for improved reliability
  retry = {
    error_message_regex = ["PrincipalNotFound"]
  }
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "diagnostic_settings" {
  for_each = var.diagnostic_settings

  name      = try(each.value.name, "diag-${each.key}")
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  body = {
    properties = {
      storageAccountId            = each.value.storage_account_resource_id
      workspaceId                 = each.value.workspace_resource_id
      eventHubAuthorizationRuleId = each.value.event_hub_authorization_rule_resource_id
      eventHubName                = each.value.event_hub_name
      marketplacePartnerId        = each.value.marketplace_partner_resource_id
      logAnalyticsDestinationType = each.value.log_analytics_destination_type

      logs = concat(
        [
          for category in each.value.log_categories : {
            category = category
            enabled  = true
            retentionPolicy = {
              enabled = false
              days    = 0
            }
          }
        ],
        [
          for group in each.value.log_groups : {
            categoryGroup = group
            enabled       = true
            retentionPolicy = {
              enabled = false
              days    = 0
            }
          }
        ]
      )

      metrics = [
        for category in each.value.metric_categories : {
          category = category
          enabled  = true
          retentionPolicy = {
            enabled = false
            days    = 0
          }
        }
      ]
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  lifecycle {
    precondition {
      condition     = var.sku_name == "StandardV2" || (length(each.value.log_categories) == 0 && length(each.value.log_groups) == 0)
      error_message = "Diagnostic Logs are only supported for the 'StandardV2' SKU. The 'Standard' SKU only supports Metrics. Please ensure 'log_categories' and 'log_groups' are empty when using 'Standard' SKU."
    }
  }
}
