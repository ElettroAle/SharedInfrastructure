output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
output "cluster_ip" {
  value = module.cluster.ip
  sensitive = false
}