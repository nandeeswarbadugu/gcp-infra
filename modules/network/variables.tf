variable "project_id" {
  description = "The GCP project ID where the network will be created."
  type        = string
}

variable "default_region" {
    description = "GCP default region if region wasn't mentioned"
    type = string
  
}

variable "network_name" {
  description = "Name of the VPC network."
  type        = string
}

variable "routing_mode" {
  description = "Network routing mode (GLOBAL or REGIONAL)."
  type        = string
  default     = "REGIONAL"
}

variable "delete_default_routes_on_create" {
  description = "Whether to delete the default internet gateway route (0.0.0.0/0) upon VPC creation."
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnet configurations."
  type = list(object({
    name                     = string
    ip_cidr_range            = string
    region                   = string
    private_ip_google_access = optional(bool, true)
    flow_logs                = optional(bool, false)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = []
}

variable "enable_nat" {
  description = "Whether to create a Cloud NAT gateway in regions where subnets reside."
  type        = bool
  default     = false
}

variable "nat_regions" {
  description = "List of regions where Cloud NAT gateways should be provisioned (only used if enable_nat is true)."
  type        = list(string)
  default     = []
}

variable "firewall_rules" {
  description = "Custom ingress firewall rules to apply to the VPC."
  type = list(object({
    name                    = string
    description             = optional(string, null)
    direction               = optional(string, "INGRESS")
    priority                = optional(number, 1000)
    source_ranges           = optional(list(string), [])
    source_tags             = optional(list(string), [])
    target_tags             = optional(list(string), [])
    target_service_accounts = optional(list(string), [])
    allow = list(object({
      protocol = string
      ports    = optional(list(string), [])
    }))
  }))
  default = []
}