terraform {
  required_version = ">= 0.13"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

locals {
  name_suffix                 = "${var.cluster_name}-${var.environment_short_name}"
  ingress_namespace           = "shared-ingress"

  nginx_ingress_chart_version = "4.4.2"
  CRDs_manifest_version       = "v1.11.0"
  cert_manager_chart_version  = "v1.8.0"
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

resource "azurerm_public_ip" "lb-public-ip" {
  name                = "pip-${local.name_suffix}"
  location            = var.location
  resource_group_name = "MC_${var.resource_group_name}_aks-${local.name_suffix}_${var.location}"
  allocation_method   = "Static"
  ip_version          = "IPv4"
  sku                 = "Standard"
  depends_on          = [ azurerm_kubernetes_cluster.aks ]
}

resource "azurerm_role_assignment" "rbac" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  depends_on                       = [ azurerm_kubernetes_cluster.aks ]
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

resource "helm_release" "ingress" {
  depends_on       = [ azurerm_kubernetes_cluster.aks ]
  name             = "${azurerm_kubernetes_cluster.aks.name}-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx/"
  chart            = "ingress-nginx"
  namespace        = local.ingress_namespace
  version          = local.nginx_ingress_chart_version
  create_namespace = true
  set {
    name = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.lb-public-ip.ip_address
  }
}

resource "kubernetes_labels" "namespace_label" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = local.ingress_namespace
  }
  labels = {
    "cert-manager.io/disable-validation" = "true"
  }
}

resource "helm_release" "cert_manager" {
  depends_on       = [ azurerm_kubernetes_cluster.aks ]
  name             = "${azurerm_kubernetes_cluster.aks.name}-cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = local.ingress_namespace
  version          = local.cert_manager_chart_version 
  create_namespace = true
  set {
    name = "installCRDs"
    value = "true"
  }
}

