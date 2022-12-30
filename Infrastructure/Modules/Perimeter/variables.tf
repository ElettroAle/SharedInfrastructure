variable "application_name" {
    type = string
    description = "The name of the application"
}
variable "workload" {
    type = string
    description = "The app service workload"
}
variable "environment_name" {
    type = string
    description = "The current environment name"
}
variable "environment_prefix" {
    type = string
    description = "The shortened current environment name"
}
variable "location" {
    type = string
    default = "West Europe"
    description = "The app service location"
}
variable "resource_group_name" {
    type = string
    description = "The app service resource group name"
}
variable "tags" {
    type = map(string)
    description = "The resource tags"
}
variable "agw_subnet_id" {
    type = string
    description = "the id of the Application Gateway subnet"
}
variable "agw_sku_name" {
    type = string
}
variable "agw_sku_tier" {
    type = string
}
variable "agw_sku_capacity" {
    type = number
}
variable "site_backend_pool_name" {
    type = string
    description = "the name of the web app to use as backend pool"
}
variable "perimeter_public_ip_id" {
    type = string
    description = "The id of the perimetral public ip"
}
variable "probe_path" {
    type = string
    description = "The path of the custom probe"
}
variable "kv_id" {
    type = string
    description = "The key vault id that contains the certificate"
}
variable "certificate" {
    type = object({
        id = string,
        name = string
    })
    description = "The id of the certificate contained in the key vault"
}
