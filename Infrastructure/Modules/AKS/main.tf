locals {
  name_suffix      = "${var.cluster_name}-${var.environment_short_name}"
}

resource "azurerm_public_ip" "lb-public-ip" {
  name                = "pip-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  ip_version          = "IPv4"
  sku                 = "Standard"
}

resource "azurerm_container_registry" "acr" {
  name                = "cr${replace(local.name_suffix, "-", "")}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = local.name_suffix
  depends_on          = [ azurerm_container_registry.acr, azurerm_public_ip.lb-public-ip ]

  default_node_pool {
    name              = "default"
    node_count        = 2
    vm_size           = "Standard_B2s"
    os_disk_size_gb   = 30
  }

  identity {
    type              = "SystemAssigned"
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    load_balancer_profile {
        outbound_ip_address_ids = [ "${azurerm_public_ip.lb-public-ip.id}" ]

    }
  }
}

resource "azurerm_role_assignment" "rbac" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  depends_on                       = [ azurerm_kubernetes_cluster.aks ]
}
