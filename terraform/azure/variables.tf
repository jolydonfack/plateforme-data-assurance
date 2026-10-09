variable "env" {
  description = "Environnement : dev, qual ou prod"
  type        = string
}

variable "location" {
  description = "Région Azure du projet"
  type        = string
  default     = "northeurope"
}
