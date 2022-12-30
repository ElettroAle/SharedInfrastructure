output "subnet_agw_id" {
    value = azurerm_subnet.snet_agw.id
}
output "subnet_site_id" {
    value = azurerm_subnet.snet_site.id
}
output "perimeter_public_ip_CIDR" {
    value = join("/", [ azurerm_public_ip.pip.ip_address, "32" ])
}
output "perimeter_public_ip_id" {
    value = azurerm_public_ip.pip.id
}