# output "ip" {
#     value = reverse(split("/", tolist(azurerm_kubernetes_cluster.aks.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
# }

output "ip" {
    value = azurerm_kubernetes_cluster.aks.network_profile.0
}