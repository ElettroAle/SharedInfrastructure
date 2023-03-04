variable "ip_address" {
    type = string
    description = "The public ip of the ingress controller"
}
variable "dns_label_prefix" {
    type = string
    description = "The dns label prefix of the Public IP, applied to the ingress controller"
}
variable "certificate_requester_email" {
    type = string
    description = "A valid email address of the organization for the certificate creation"
    sensitive = true
}
