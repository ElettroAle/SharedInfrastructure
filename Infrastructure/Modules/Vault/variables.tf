variable "application_name" {
    type = string
    description = "The name of the application"
}
variable "workload" {
    type = string
    description = "The key vault worlkload"
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
variable "tags" {
    type = map(string)
    description = "The resource tags"
}
variable "resource_group_name" {
    type = string
    description = "The app service resource group name"
}
variable "object_ids" {
    type = set(string)
    description = "Object ids to enable"
}
variable "agent_object_ids" {
    type = set(string)
    description = "The ObjectId of the agents"
}
variable "secrets" {
  type = list(object({
    name = string
    value = string
  }))
  default = []
}
variable "keys" {
  type = list(object({
    name = string
  }))
  default = []
}
variable "pfx_certificates" {
  type = list(object({
    file_path = string
    name = string
    password = string
  }))
  default = []
}