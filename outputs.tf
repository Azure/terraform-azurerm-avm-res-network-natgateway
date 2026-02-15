output "public_ip_resource" {
  description = "The public IP resource."
  value       = azapi_resource.public_ip
}

# TODO: insert outputs here.
output "resource" {
  description = "The NAT Gateway resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The ID of the NAT Gateway."
  value       = azapi_resource.this.id
}
