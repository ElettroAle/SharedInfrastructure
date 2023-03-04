terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

resource "azurerm_dns_zone" "zone" {
  name                            = var.domain_name
  resource_group_name             = var.resource_group_name
}

resource "azurerm_dns_a_record" "record" {
  name                            = var.domain_name
  records                         = [ var.ip_address ]
  resource_group_name             = var.resource_group_name
  ttl                             = 3600
  zone_name                       = azurerm_dns_zone.zone.name
  tags                            = var.tags
  depends_on                      = [ azurerm_dns_zone.zone ] 
}