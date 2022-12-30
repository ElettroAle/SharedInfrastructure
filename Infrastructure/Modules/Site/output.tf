output "app_name" {
    value = azurerm_app_service.app.name
}
output "app_object_id" {
    value = azurerm_app_service.app.identity[0].principal_id
}
output "redis_connection_string" {
    value = azurerm_redis_cache.redis.primary_connection_string
}