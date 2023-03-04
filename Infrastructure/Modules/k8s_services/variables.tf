variable "certificate_requester_email" {
    type = string
    description = "A valid email address of the organization for the certificate creation"
    sensitive = true
}
variable "ingress_annotations" {
    type = map(string)
    description = "the annotations that you should add to the ingress controller"
}
