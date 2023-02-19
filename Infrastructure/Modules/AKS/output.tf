output "ip" {
    value = azurerm_public_ip.lb-public-ip.ip_address
    sensitive = false
}