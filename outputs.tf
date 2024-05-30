# TODO: insert outputs here.
output "resource" {
  description = "The NAT Gateway resource."
  value       = azurerm_nat_gateway.this
}

output "resource_id" {
  description = "The ID of the NAT Gateway."
  value       = azurerm_nat_gateway.this.id
}
