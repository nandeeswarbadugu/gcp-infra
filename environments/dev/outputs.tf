output "network_id" {
  description = "VPC self link / ID"
  value       = module.network.network_id
}

output "network_name" {
  description = "VPC resource name"
  value       = module.network.network_name
}

output "subnets" {
  description = "Map of created subnets"
  value       = module.network.subnets
}