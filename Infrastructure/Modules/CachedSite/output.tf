output "app_name" {
    value = module.site.app_name
}
output "app_object_id" {
    value = module.site.app_object_id
}
output "redis_connection_string" {
    value = azurerm_redis_cache.redis.primary_connection_string 
}
