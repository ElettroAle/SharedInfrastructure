variable "cluster_name" {
    type = string
    description = "The name of the cluster"
}
variable "environment_short_name" {
    type = string
    description = "The current environment short name"
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