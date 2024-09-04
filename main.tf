resource "azurerm_public_ip_prefix" "this" {
  count = var.public_ip_prefix_length > 0 ? 1 : 0

  location            = var.location
  name                = "${var.name}-pippf"
  resource_group_name = var.resource_group_name
  prefix_length       = var.public_ip_prefix_length
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "this" {
  count = var.public_ip_prefix_length > 0 ? 1 : 0

  nat_gateway_id      = azurerm_nat_gateway.this.id
  public_ip_prefix_id = azurerm_public_ip_prefix.this[0].id
}

resource "azurerm_public_ip" "this" {
  for_each = var.public_ips

  allocation_method       = var.public_ip_configuration.allocation_method
  location                = var.location
  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  ddos_protection_mode    = var.public_ip_configuration.ddos_protection_mode
  ddos_protection_plan_id = var.public_ip_configuration.ddos_protection_plan_id
  domain_name_label       = var.public_ip_configuration.domain_name_label
  idle_timeout_in_minutes = var.public_ip_configuration.idle_timeout_in_minutes
  ip_version              = var.public_ip_configuration.ip_version
  sku                     = var.public_ip_configuration.sku
  sku_tier                = var.public_ip_configuration.sku_tier
  tags                    = var.public_ip_configuration.tags != null && var.public_ip_configuration != {} ? var.public_ip_configuration.tags : var.tags
  zones                   = var.public_ip_configuration.zones
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  for_each = var.public_ips

  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.this[each.key].id
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

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = var.subnet_associations

  nat_gateway_id = azurerm_nat_gateway.this.id
  subnet_id      = each.value.resource_id
}

resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_nat_gateway.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_nat_gateway.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}