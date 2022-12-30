output "app_site_name" {
    value = module.site.app_name
}
output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}