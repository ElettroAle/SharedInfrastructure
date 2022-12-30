locals {
  name_suffix      = "${var.workload}-${var.environment_prefix}"
  agw_subnet_name  = "snet-${var.application_name}-agw"
  site_subnet_name = "snet-${var.application_name}-site"
  is_production    = var.environment_prefix == "prod" ? true : false
}

locals {
  vnet_name         = "vnet-${var.application_name}-${local.name_suffix}"
  vnet_addess_space = ["10.1.0.0/16"]
}

# resource "azurerm_virtual_network" "vnet" {
#   name                = local.vnet_name
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   address_space       = local.vnet_addess_space
#   tags                = var.tags

#   ddos_protection_plan {
#     enable = true
#     id     = var.ddos_plan_id
#   }
# }

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = local.vnet_addess_space
  tags                = var.tags
}

resource "azurerm_subnet" "snet_agw" {
  name                 = local.agw_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/24"]
  depends_on           = [ azurerm_virtual_network.vnet ]
}

resource "azurerm_subnet" "snet_site" {
  name                 = local.site_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
  depends_on           = [ azurerm_virtual_network.vnet ]

  delegation {
      name = "${local.site_subnet_name}_delegation"

      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
}

resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.application_name}-${var.environment_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags

  lifecycle {
    prevent_destroy = true
  }
}