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
variable "ddos_plan_id" {
    type = string
    description = "The DDOS plan protection id"
}