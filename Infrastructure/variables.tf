variable "application_name" {
    type = string
    description = "The name of the application"
    default = "fit"
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
    description = "Resources location"
}
variable "site_plan_sku" {
    type = object({
        tier = string
        size = string
        capacity = number
    })
    description = "SKU of the site web application"
}
variable "site_redis_sku" {
  type = object({
      capacity = string
      family = string
      sku = string
  })
}
variable "tags" {
    type = map(string)
    description = "The resource tags"
}
variable "site_configurations" {
    type = object({
        Eclexia__SliderSubcategoryKey = string
        Eclexia__IsSpecialCategory = string
        Eclexia__TokenUrl = string, 
        Eclexia__ContentApiHostName = string,
        Eclexia__UserApiHostName = string,
        Eclexia__FavoriteSports__0__LocalizedKey = string,
        Eclexia__FavoriteSports__0__Value = string,
        Eclexia__FavoriteSports__1__LocalizedKey = string,
        Eclexia__FavoriteSports__1__Value = string,
        Eclexia__FavoriteSports__2__LocalizedKey = string,
        Eclexia__FavoriteSports__2__Value = string,
        Eclexia__FavoriteSports__3__LocalizedKey = string,
        Eclexia__FavoriteSports__3__Value = string,
    })
    description = "An object that contains the site configurations"
}
variable "agw_sku" {
    type = object({
        name     = string
        tier     = string
        capacity = number
    })
    description = "An object that contains application gateway sku informations"
}
variable "ECLEXIA_TOKEN_CLIENTID" {
    type = string
    sensitive = true
}
variable "ECLEXIA_TOKEN_CLIENTSECRET" {
    type = string
    sensitive = true
}
variable "ECLEXIA_USER_SUBSCRIPTIONID" {
    type = string
    sensitive = true
}
variable "AGENT_OBJECT_ID" {
    type = string
    sensitive = false
}
variable "CERTIFICATE_PFX_PATH" {
    type = string
    sensitive = false
    description = "The path of the .pfx file"
}
variable "CERTIFICATE_PFX_PASSWORD" {
    type = string
    sensitive = true
    description = "The password of the .pfx file"
}
variable "DEVICE_COOKIE_ENCRYPTION_KEY" {
    type = string
    sensitive = true
    description = "The device cookie encryption key"
}
variable "DEVICE_COOKIE_ENCRYPTION_PADDING" {
    type = string
    sensitive = true
    description = "The device cookie encryption key"
}
variable "DDOS_PROTECTION_PLAN_ID" {
    type = string
    sensitive = false
    description = "The DDOS plan protection id"
}