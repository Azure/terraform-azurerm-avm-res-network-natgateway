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

resource "azapi_resource" "this_vnet" {
  location  = azapi_resource.this.location
  name      = module.naming.virtual_network.name_unique
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Network/virtualNetworks@2024-01-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["10.0.0.0/16"]
      }
    }
  }
  tags = local.tags
}

resource "azapi_resource" "this_subnet" {
  name      = "${module.naming.subnet.name_unique}-1"
  parent_id = azapi_resource.this_vnet.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  body = {
    properties = {
      addressPrefix = "10.0.1.0/24"
    }
  }
  response_export_values = ["properties.addressPrefix"]
}

# This is the module call
module "natgateway" {
  source = "../../"

  location = azapi_resource.this.location
  # source             = "Azure/avm-res-network-natgateway/azurerm"
  name                = module.naming.nat_gateway.name_unique
  resource_group_name = azapi_resource.this.name
  enable_telemetry    = true
  public_ip_configuration = {
    public_ip_1 = {
      idle_timeout_in_minutes = 15
      sku                     = "Standard"
      zones                   = ["1", "2"]
    }
    public_ip_2 = {
      idle_timeout_in_minutes = 10
      sku                     = "Standard"
      zones                   = ["1", "2"]
    }
    public_ip_prefix_1 = {
      idle_timeout_in_minutes = 5
      sku                     = "Standard"
      zones                   = ["1", "2"]
    }
  }
  public_ip_prefixes = {
    public_ip_prefix_1 = {
      name          = "nat_gw_prefix1"
      prefix_length = 30
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
  subnet_associations = {
    subnet_1 = {
      resource_id    = azapi_resource.this_subnet.id
      address_prefix = azapi_resource.this_subnet.output.properties.addressPrefix
    }
  }
}
