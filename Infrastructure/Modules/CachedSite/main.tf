module "site" {
  source                          = "../Site"
  application_name                = var.application_name
  workload                        = var.workload
  environment_name                = var.environment_name
  environment_prefix              = var.environment_prefix
  resource_group_name             = var.resource_group_name
  location                        = var.location
  tags                            = var.tags 
  tier                            = var.tier
  size                            = var.size
  capacity                        = var.capacity
  configurations                  = var.configurations
  site_subnet_id                  = var.site_subnet_id
  access_restriction_rules        = var.access_restriction_rules
}

resource "azurerm_redis_cache" "redis" {
  name                            = "redis-${var.application_name}-${var.workload}-${var.environment_prefix}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  capacity                        = var.redis_capacity
  family                          = var.redis_family
  sku_name                        = var.redis_sku
  enable_non_ssl_port             = false
  minimum_tls_version             = "1.2"
  tags                            = var.tags
  depends_on                      = [ module.site ]

  redis_configuration {
  }
}