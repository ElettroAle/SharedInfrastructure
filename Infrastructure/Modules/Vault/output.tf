output "id" {
    value = azurerm_key_vault.kv.id
}
output "certificates" {
    value = tolist([
        for cert in azurerm_key_vault_certificate.cert : { 
            name = cert.name
            id = cert.secret_id
        }
    ])
}