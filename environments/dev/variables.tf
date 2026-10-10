
variable "project_id" {
  description = "GCP Project ID for development"
  type        = string
}

variable "default_region" {
  description = "Default GCP region for resources"
  type        = string

}

variable "environment" {
  description = "Target deployment environment"
  type        = string

}
