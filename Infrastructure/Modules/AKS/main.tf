locals {
  name_suffix      = "${var.cluster_name}-${var.environment_short_name}"
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
  depends_on          = [ azurerm_container_registry.acr ]

  default_node_pool {
    name              = "default"
    node_count        = 2
    vm_size           = "Standard_B2s"
    os_disk_size_gb   = 30
  }

  identity {
    type              = "SystemAssigned"
  }
  
}

resource "azurerm_role_assignment" "rbac" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  depends_on                       = [ azurerm_kubernetes_cluster.aks ]
}

data "azurerm_public_ip" "ip" {
  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.aks.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
}