# Configure the Azure provider
terraform {
  backend "azurerm" {
    resource_group_name   = "rg-managing"
    storage_account_name  = "samanaging"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
        recover_soft_deleted_key_vaults = true
        purge_soft_delete_on_destroy = true
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.application_name}-frontend-${var.environment_prefix}"
  location = var.location
  tags = var.tags
}

module "network" {
  source                          = "./Modules/Network"
  application_name                = var.application_name
  workload                        = "frontend"
  environment_name                = var.environment_name
  environment_prefix              = var.environment_prefix
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  ddos_plan_id                    = var.DDOS_PROTECTION_PLAN_ID
  tags                            = var.tags 
}

module "site" {
  source                          = "./Modules/Site"
  application_name                = var.application_name
  workload                        = "site"
  environment_name                = var.environment_name
  environment_prefix              = var.environment_prefix
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  tags                            = var.tags 
  tier                            = var.site_plan_sku.tier
  size                            = var.site_plan_sku.size
  capacity                        = var.site_plan_sku.capacity
  configurations                  = var.site_configurations
  site_subnet_id                  = module.network.subnet_site_id
  access_restriction_rules        = [ { name = "gateway", CIDR = module.network.perimeter_public_ip_CIDR, allow = true }]
  depends_on                      = [ module.network ]

  redis_sku                       = var.site_redis_sku.sku
  redis_family                    = var.site_redis_sku.family
  redis_capacity                  = var.site_redis_sku.capacity
}

module "vault" {
  source                          = "./Modules/Vault"
  application_name                = var.application_name
  workload                        = "site"
  environment_prefix              = var.environment_prefix
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  tags                            = var.tags 
  agent_object_ids                = [ var.AGENT_OBJECT_ID ]
  object_ids                      = [ module.site.app_object_id ]
  secrets                         = [
    { name = "DeviceCookie--EncryptionPadding",   value = var.DEVICE_COOKIE_ENCRYPTION_PADDING },
    { name = "DeviceCookie--EncryptionKey",       value = var.DEVICE_COOKIE_ENCRYPTION_KEY },
    { name = "ApiCache--ConnectionString",        value = module.site.redis_connection_string },
    { name = "Eclexia--TokenClientId",            value = var.ECLEXIA_TOKEN_CLIENTID },
    { name = "Eclexia--TokenClientSecret" ,       value = var.ECLEXIA_TOKEN_CLIENTSECRET },
    { name = "Eclexia--UserSubscriptionId" ,      value = var.ECLEXIA_USER_SUBSCRIPTIONID }
  ]
  keys                            = [
    { name = "${var.application_name}-cookie-${var.environment_prefix}" },
  ]
  pfx_certificates                = [{ file_path = var.CERTIFICATE_PFX_PATH, name = "certificate-fit-${var.environment_prefix}" , password = var.CERTIFICATE_PFX_PASSWORD }]
  depends_on                      = [ module.site ]
}

module "perimeter" {
  source                          = "./Modules/Perimeter"
  application_name                = var.application_name
  workload                        = "perimeter"
  environment_name                = var.environment_name
  environment_prefix              = var.environment_prefix
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  tags                            = var.tags 
  agw_subnet_id                   = module.network.subnet_agw_id
  agw_sku_name                    = var.agw_sku.name
  agw_sku_tier                    = var.agw_sku.tier
  agw_sku_capacity                = var.agw_sku.capacity
  site_backend_pool_name          = module.site.app_name
  perimeter_public_ip_id          = module.network.perimeter_public_ip_id
  kv_id                           = module.vault.id
  certificate                     = module.vault.certificates[0]
  probe_path                      = "/health"
  depends_on                      = [ module.vault, module.network ]
}