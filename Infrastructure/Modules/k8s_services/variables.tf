variable "ip_address" {
    type = string
    description = "The public ip of the ingress controller"
}
variable "certificate_requester_email" {
    type = string
    description = "A valid email address of the organization for the certificate creation"
    sensitive = true
}
