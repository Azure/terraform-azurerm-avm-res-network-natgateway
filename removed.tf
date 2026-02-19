removed {
  from = azurerm_nat_gateway_public_ip_association.this

  lifecycle {
    destroy = false
  }
}
