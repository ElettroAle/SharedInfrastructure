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
variable "tier" {
    type = string
    description = "the app service tier"
}
variable "size" {
    type = string
    description = "The app service size"
}
variable "capacity" {
    type = string
    description = "The app service instance count"
}
variable "tags" {
    type = map(string)
    description = "The resource tags"
}
variable "resource_group_name" {
    type = string
    description = "The app service resource group name"
}
variable "configurations" {
    type = any
    description = "the app service configurations"
}
variable "site_subnet_id" {
    type = string
    description = "the id of the Webb App delegated subnet"
}
variable "access_restriction_rules" {
    type = list(object ({
        name = string
        CIDR = string
        allow = bool
    }))
    default = []
    description = "the allowed ips"
}
variable "redis_family" {
    type = string
    description = "the redis family"
}
variable "redis_capacity" {
    type = string
    description = "The redis capacity"
}
variable "redis_sku" {
    type = string
    description = "The redis sku"
}