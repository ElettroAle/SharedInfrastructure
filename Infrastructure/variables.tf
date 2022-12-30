variable "cluster_name" {
    type = string
    description = "The name of the aks cluster"
    default = "cluster"
}
variable "subscription_id" {
    type = string
    description = "the ID of the Azure subscription"
}
variable "tenant_id" {
    type = string
    description = "the ID of the Azure Tenant"
}
variable "environment_shortName" {
    type = string
    description = "The short name of the solution environment"
}
variable "location" {
    type = string
    default = "West Europe"
    description = "Resources location"
}
variable "tags" {
    type = map(string)
    description = "The resource tags"
    default = { }
}
variable "UID_CLIENT_ID" {
    type = string
    description = "The Id of the user assigned managed identity"
}
variable "IS_LOCAL" {
    type = bool
    description = "States if the execution is in a local device"
}