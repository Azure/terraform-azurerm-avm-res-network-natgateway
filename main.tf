resource "azurerm_public_ip_prefix" "this" {
  count = var.public_ip_prefix_length > 0 ? 1 : 0

  name = "${var.name}-pippf"

  location            = var.location
  resource_group_name = var.resource_group_name

  prefix_length = var.public_ip_prefix_length

  tags = var.tags
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "this" {
  count = var.public_ip_prefix_length > 0 ? 1 : 0

  public_ip_prefix_id = azurerm_public_ip_prefix.this[0].id
  nat_gateway_id      = azurerm_nat_gateway.this.id
}

resource "azurerm_nat_gateway" "this" {
  location                = var.location
  name                    = var.name
  resource_group_name     = var.resource_group_name
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  sku_name                = var.sku_name
  tags                    = var.tags
  zones                   = var.zones

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_management_lock" "this" {
  count = var.lock.kind != "None" ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_nat_gateway.this.id
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_nat_gateway.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}