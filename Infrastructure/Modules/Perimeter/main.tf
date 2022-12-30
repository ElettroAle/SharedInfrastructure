locals {
  name_suffix         = "${var.workload}-${var.environment_prefix}"
  is_production       = var.environment_prefix == "prod" ? true : false
}

locals {
  use_https_listener  = local.is_production
  enable_autoscaling  = local.is_production
  waf_configuration = {
    enabled                  = local.is_production,
    file_upload_limit_mb     = 100,
    firewall_mode            = "Detection",
    max_request_body_size_kb = 128,
    request_body_check       = true,
    rule_set_type            = "OWASP",
    rule_set_version         = "3.0"
  }
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}
  
# key vault access
data "azurerm_client_config" "current" {}
locals {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_user_assigned_identity" "id_agw" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "id-fit-${local.name_suffix}"
  tags                = var.tags
}

resource "azurerm_key_vault_access_policy" "policy_agw" {
  key_vault_id = var.kv_id
  tenant_id    = local.tenant_id
  object_id    = azurerm_user_assigned_identity.id_agw.principal_id
  secret_permissions = [ "get" ]
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name                 = "beap-${var.site_backend_pool_name}"
  frontend_port_80                          = "feport-${local.name_suffix}-80"
  frontend_port_443                         = "feport-${local.name_suffix}-443"
  frontend_ip_configuration_name            = "feip-${local.name_suffix}"
  http_setting_name                         = "http-${local.name_suffix}"
  https_setting_name                        = "https-${local.name_suffix}"
  listener_http_name                        = "listener-http-${local.name_suffix}"
  listener_https_name                       = "listener-https-${local.name_suffix}"
  http_request_routing_rule_name            = "rule-http-${local.name_suffix}"
  https_request_routing_rule_name           = "rule-https-${local.name_suffix}"
  redirect_configuration_name               = "redirect-http-to-https"
  certificate_name                          = var.certificate.name
  certificate_id                            = var.certificate.id
  http_probe_name                           = "probe-http-${local.name_suffix}"
  https_probe_name                          = "probe-https-${local.name_suffix}"
}

resource "azurerm_application_gateway" "agw" {
  depends_on = [ 
       azurerm_key_vault_access_policy.policy_agw, 
       time_sleep.wait_60_seconds
   ]

  name                = "agw-${var.application_name}-${local.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  enable_http2        = true

  sku {
    name     = var.agw_sku_name
    tier     = var.agw_sku_tier
    capacity = var.agw_sku_capacity
  }

  waf_configuration {
    enabled                  = local.waf_configuration.enabled
    file_upload_limit_mb     = local.waf_configuration.file_upload_limit_mb
    firewall_mode            = local.waf_configuration.firewall_mode
    max_request_body_size_kb = local.waf_configuration.max_request_body_size_kb
    request_body_check       = local.waf_configuration.request_body_check
    rule_set_type            = local.waf_configuration.rule_set_type
    rule_set_version         = local.waf_configuration.rule_set_version

  }

  # sku {
  #   name          = var.agw_sku_name
  #   tier          = var.agw_sku_tier
  # }
  # autoscale_configuration {
    
  #   min_capacity = 1
  #   max_capacity = var.agw_sku_capacity
  # }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.id_agw.id]
  }

  gateway_ip_configuration {
    name      = "agw-ip-configuration"
    subnet_id = var.agw_subnet_id
  }

  frontend_port {
    name = local.frontend_port_80
    port = 80
  }

  frontend_port {
     name  = local.frontend_port_443
     port  = 443
  }

  ssl_certificate {
    name                = local.certificate_name
    key_vault_secret_id = local.certificate_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.perimeter_public_ip_id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = [ "${var.site_backend_pool_name}.azurewebsites.net" ]
  }

  probe {
    name                                      = local.https_probe_name
    pick_host_name_from_backend_http_settings = true
    interval                                  = 30
    timeout                                   = 30
    path                                      = var.probe_path
    protocol                                  = "Https"
    unhealthy_threshold                       = 3
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    # probe_name                          = local.http_probe_name
  }

  backend_http_settings {
    name                                = local.https_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = local.https_probe_name
  }

  http_listener {
    name                           = local.listener_http_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_80
    protocol                       = "Http"
  }

  http_listener {
    name                           = local.listener_https_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_443
    protocol                       = "Https"
    ssl_certificate_name           = local.certificate_name
  }

  redirect_configuration {
    name                        = local.redirect_configuration_name
    redirect_type               = "Permanent" # options: ["Permanent", "Temporary", "Found", "SeeOther"]
    target_listener_name        = local.listener_https_name
    include_query_string        = true
    include_path                = true
  }

  request_routing_rule {
    name                        = local.http_request_routing_rule_name
    rule_type                   = "Basic"
    http_listener_name          = local.listener_http_name
    redirect_configuration_name = local.redirect_configuration_name
    # sostituire questa riga con quelle sotto
    /* backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.https_setting_name */
  }

  request_routing_rule {
    name                       = local.https_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_https_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.https_setting_name
  }
}