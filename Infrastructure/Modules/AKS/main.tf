locals {
  name_suffix      = "${var.cluster_name}-${var.environment_short_name}"
}


# Add the public IP address and network security group to the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = local.name_suffix

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }
  
}

# Output the AKS cluster configuration
output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}