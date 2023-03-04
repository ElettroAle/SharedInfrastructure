variable "cluster_name" {
  type        = string
  description = "The name of the aks cluster"
  default     = "cluster"
}
variable "environment_short_name" {
  type        = string
  description = "The short name of the solution environment"
}
variable "location" {
  type        = string
  default     = "West Europe"
  description = "Resources location"
}
variable "CERTIFICATE_REQUESTER_EMAIL" {
  type = string
  description = "A valid email address of the organization for the certificate creation"
  sensitive = true
}
variable "dns_label_prefix" {
  type = string
  description = "the public ip DNS label name prefix. Used for FQDN definition"
}
variable "tags" {
  type        = map(string)
  description = "The resource tags"
  default     = {}
}