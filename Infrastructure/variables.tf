variable "cluster_name" {
  type        = string
  description = "The name of the aks cluster"
  default     = "cluster"
}
variable "environment_shortName" {
  type        = string
  description = "The short name of the solution environment"
}
variable "location" {
  type        = string
  default     = "West Europe"
  description = "Resources location"
}
variable "tags" {
  type        = map(string)
  description = "The resource tags"
  default     = {}
}