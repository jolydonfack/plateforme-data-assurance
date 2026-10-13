variable "env" {
  description = "Environnement : dev, qual ou prod"
  type        = string
}

variable "location" {
  description = "Région Azure du projet"
  type        = string
  default     = "northeurope"
}

variable "vnet_cidr" {
  type        = string
  description = "Plage d adresses du VNet"
}

variable "enable_defender_storage" {
  type    = bool
  default = false
}

variable "admin_object_id" {
  type = string
}
