terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
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

  dynamic "set" {
    for_each = var.ingress_annotations
    content {
      name  = set.key
      value = set.value
    }
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

resource "kubernetes_manifest" "clusterissuer_letsencrypt" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt"
    }
    "spec" = {
      "acme" = {
        "email" = "${var.certificate_requester_email}"
        "privateKeySecretRef" = {
          "name" = "letsencrypt"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
                "podTemplate" = {
                  "spec" = {
                    "nodeSelector" = {
                      "kubernetes.io/os" = "linux"
                    }
                  }
                }
              }
            }
          },
        ]
      }
    }
  }
}
