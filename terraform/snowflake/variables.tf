variable "env" {
  description = "Environnement : dev, qual ou prod"
  type        = string
}

variable "location" {
  description = "Région (information, non utilisée par Snowflake)"
  type        = string
  default     = "northeurope"
}
