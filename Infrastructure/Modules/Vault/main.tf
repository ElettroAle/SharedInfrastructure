data "azurerm_client_config" "current" {}

locals {
  tenant_id = data.azurerm_client_config.current.tenant_id
  secrets = {for item in var.secrets:  item.name => item}
  pfx_certificates = {for item in var.pfx_certificates:  item.name => item}
  object_ids = {for item in compact(var.object_ids):  item => item}
  agent_object_ids = {for item in compact(var.agent_object_ids):  item => item}
}

resource "azurerm_key_vault_secret" "secret" {
  for_each     = local.secrets
  name         = each.value.name
  value        = each.value.value
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [ azurerm_key_vault.kv, azurerm_key_vault_access_policy.policy_agents ]
}

resource "azurerm_key_vault_access_policy" "policy" {
  for_each                  = local.object_ids
  key_vault_id              = azurerm_key_vault.kv.id
  tenant_id                 = local.tenant_id
  object_id                 = each.value
  secret_permissions        = [ "Get", "List", "Set", "Delete", "Recover" ]
  depends_on                = [ azurerm_key_vault.kv ]
}

resource "azurerm_key_vault_access_policy" "policy_agents" {
  for_each                  = local.agent_object_ids
  key_vault_id              = azurerm_key_vault.kv.id
  tenant_id                 = local.tenant_id
  object_id                 = each.value
  secret_permissions        = [ 
    "Get", 
    "List", 
    "Set", 
    "Delete", 
    "Recover", 
    "Purge" 
  ]
  certificate_permissions   = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update",
    "Purge"
  ]
  depends_on                = [ azurerm_key_vault.kv ]
}

resource "time_sleep" "wait_120_seconds" {
  depends_on = [ azurerm_key_vault_access_policy.policy, time_sleep.wait_120_seconds ]
  create_duration = "120s"
}

resource "azurerm_key_vault_certificate" "cert" {
  for_each     = local.pfx_certificates
  name         = each.value.name
  key_vault_id = azurerm_key_vault.kv.id

  certificate {
    contents = filebase64(each.value.file_path)
    password = each.value.password
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }

  depends_on   = [ time_sleep.wait_120_seconds, azurerm_key_vault.kv, azurerm_key_vault_access_policy.policy_agents ]
}

resource "azurerm_key_vault" "kv" {
  name                            = "kv-${var.application_name}-${var.workload}-${var.environment_prefix}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  enabled_for_disk_encryption     = true
  tenant_id                       = local.tenant_id
  enabled_for_deployment          = true
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  enabled_for_template_deployment = true
  sku_name                        = "standard"
  tags                            = var.tags

  network_acls {
    default_action                = "Allow"
    bypass                        = "AzureServices"
  }
}
