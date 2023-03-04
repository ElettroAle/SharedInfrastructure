variable "ip_address" {
    type = string
    description = "The public ip of the ingress controller"
}
variable "domain_name" {
    type = string
    description = "The name of the A record"
}
variable "resource_group_name" {
    type = string
    description = "The app service resource group name"
}
variable "tags" {
  type        = map(string)
  description = "The resource tags"
  default     = {}
}
