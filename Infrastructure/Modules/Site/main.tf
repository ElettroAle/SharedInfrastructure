# list of ACLs
locals{
    allowedIps = [
      for item in var.access_restriction_rules:  { 
        action = item.allow ? "Allow" : "Deny"
        ip_address = item.CIDR
        name = item.name
        priority = 1
        subnet_id = null
        virtual_network_subnet_id = null
        service_tag = null
      }
    ]
}

#app service plan
resource "azurerm_app_service_plan" "asp" {
  name                = "asp-fit-${var.workload}-${var.environment_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku {
    tier = var.tier
    size = var.size
    capacity = var.capacity
  }
}

#application insights
resource "azurerm_application_insights" "ai" {
  name                = "ai-fit-${var.workload}-${var.environment_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

#basic configuration
locals { 
  full_configurations = merge({
    Environment = var.environment_prefix
    DOTNET_ENVIRONMENT = var.environment_name
    ASPNETCORE_ENVIRONMENT = var.environment_name
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.ai.instrumentation_key
    WEBSITE_RUN_FROM_PACKAGE = 1
    Vault__Name = "kv-fit-${var.workload}-${var.environment_prefix}"
  }, var.configurations)
}

#app service
resource "azurerm_app_service" "app" {
  name                = "app-fit-${var.workload}-${var.environment_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  tags                = var.tags

  site_config {
    dotnet_framework_version = "v4.0"
    use_32_bit_worker_process = var.tier == "Standard" ? false : true //True for free and shared tiers.  False for Standard, // It works only in upscale, because before change the worker it's necessary to change the asp, and it fails
    always_on         = var.tier == "Shared" ? false : true 
    ip_restriction    = local.allowedIps
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = local.full_configurations

  depends_on = [
    azurerm_application_insights.ai,
    azurerm_app_service_plan.asp,
  ]
}

resource "azurerm_app_service_virtual_network_swift_connection" "connection" {
  count           = var.tier == "Shared" ? 0 : 1
  app_service_id  = azurerm_app_service.app.id
  subnet_id       = var.site_subnet_id

  depends_on      = [ azurerm_app_service.app ]
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
  depends_on                      = [ azurerm_app_service.app ]

  redis_configuration {
  }
}
