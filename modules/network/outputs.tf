output "network_id" {
  description = "The URI/ID of the VPC being created."
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "The name of the VPC being created."
  value       = google_compute_network.vpc.name
}

output "subnets" {
  description = "Map of all created subnets with their IDs, CIDRs, and self-links."
  value = {
    for k, v in google_compute_subnetwork.subnets : k => {
      id            = v.id
      name          = v.name
      region        = v.region
      ip_cidr_range = v.ip_cidr_range
      self_link     = v.self_link
    }
  }
}

output "routers" {
  description = "Map of Cloud Routers created for NAT."
  value       = { for k, v in google_compute_router.router : k => v.name }
}