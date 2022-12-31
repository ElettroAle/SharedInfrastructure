terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  cloud {
    organization = "ElettroAle"

    workspaces {
      name = "shared-infrastructure"
    }
  }
}

provider "azurerm" {
  features {} 
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