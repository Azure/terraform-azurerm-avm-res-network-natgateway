moved {
  from = azurerm_nat_gateway.this
  to   = azapi_resource.this
}

moved {
  from = azurerm_public_ip.this
  to   = azapi_resource.public_ip
}

moved {
  from = azurerm_management_lock.this
  to   = azapi_resource.lock
}

moved {
  from = azurerm_role_assignment.this
  to   = azapi_resource.role_assignment
}
