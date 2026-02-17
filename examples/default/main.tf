# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.11.0"

  has_availability_zones = true
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.3"
}

locals {
  tags = {
    scenario = "default"
  }
}

# This is required for resource modules
resource "azapi_resource" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  tags     = local.tags
}

# This is the module call
module "natgateway" {
  source = "../../"

  location = azapi_resource.this.location
  # source             = "Azure/avm-res-network-natgateway/azurerm"
  name             = module.naming.nat_gateway.name_unique
  parent_id        = azapi_resource.this.id
  enable_telemetry = true
  public_ip_configuration = {
    public_ip_1 = {
      idle_timeout_in_minutes = 15
      sku                     = "Standard"
      zones                   = ["1", "2", "3"]
    }
    public_ip_2 = {
      idle_timeout_in_minutes = 10
      sku                     = "Standard"
      zones                   = ["1", "2", "3"]
    }
  }
  public_ips = {
    public_ip_1 = {
      name = "nat_gw_pip1"
    }
    public_ip_2 = {
      name = "nat_gw_pip2"
    }
  }
  sku_name = "Standard"
}
