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

module "cluster" {
  source                          = "./Modules/AKS"
  cluster_name                    = var.cluster_name
  environment_short_name          = var.environment_short_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  tags                            = var.tags 
}

resource "azurerm_dns_zone" "zone" {
  name                = "elettroale.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "a_record" {
  name = "elettroale.com"
  records = [
    "20.73.229.161"
    # module.cluster.ip
  ]
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 3600
  zone_name           = azurerm_dns_zone.zone.name

  tags = var.tags
}