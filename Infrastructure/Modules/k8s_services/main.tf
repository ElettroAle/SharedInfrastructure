terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
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
  ingress_namespace           = "shared-ingress"
  cert_manager_namespace      = "cert-manager"
  nginx_ingress_chart_version = "4.4.2"
  cert_manager_chart_version  = "v1.8.0"
}

resource "helm_release" "ingress" {
  name             = "nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx/"
  chart            = "ingress-nginx"
  namespace        = local.ingress_namespace
  version          = local.nginx_ingress_chart_version
  create_namespace = true
  set {
    name = "controller.service.loadBalancerIP"
    value = var.ip_address
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
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = local.cert_manager_namespace
  version          = local.cert_manager_chart_version 
  create_namespace = true
  set {
    name = "installCRDs"
    value = "true"
  }
}