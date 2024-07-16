output "public_ip_prefix_value" {
  description = "The CIDR provisioned for the public IP prefix"
  value       = azurerm_public_ip_prefix.this.ip_prefix
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
