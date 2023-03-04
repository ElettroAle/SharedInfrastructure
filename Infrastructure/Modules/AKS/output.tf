output "kube_config" {
    value = azurerm_kubernetes_cluster.aks.kube_config.0
}
output "ip" {
    value = azurerm_public_ip.lb-public-ip.ip_address
}
output "fqdn" {
    value = azurerm_public_ip.lb-public-ip.fqdn
}