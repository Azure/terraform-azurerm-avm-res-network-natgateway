output "public_ip_prefix_value" {
  description = "The CIDR provisioned for the public IP prefix"
  value       = var.public_ip_prefix_length != null && var.public_ip_prefix_length > 0 ? azurerm_public_ip_prefix.this[0].ip_prefix : null
}

# TODO: insert outputs here.
output "resource" {
  description = "The NAT Gateway resource."
  value       = azurerm_nat_gateway.this
}

output "resource_id" {
  description = "The ID of the NAT Gateway."
  value       = azurerm_nat_gateway.this.id
}
