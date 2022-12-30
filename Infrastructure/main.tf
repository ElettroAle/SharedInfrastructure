# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name   = "rg-managing"
    storage_account_name  = "samanaging"
    container_name        = "terraform"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  use_msi = var.IS_LOCAL ? false : true
  subscription_id       = var.subscription_id
  tenant_id             = var.tenant_id
  client_id             = var.UID_CLIENT_ID
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.cluster_name}"
  location = var.location
  tags     = var.tags
}

# module "cluster" {
#   source                          = "./Modules/AKS"
#   cluster_name                    = var.cluster_name
#   environment_name                = var.environment_name
#   environment_prefix              = var.environment_prefix
#   resource_group_name             = azurerm_resource_group.rg.name
#   location                        = azurerm_resource_group.rg.location
#   tags                            = var.tags 
# }