

# environments/dev/main.tf

module "network" {
  source = "../../modules/network"

  project_id                      = var.project_id
  network_name                    = "${var.environment}-vpc"
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = false

  subnets = [
    {
      name                     = "${var.environment}-subnet-apps-${var.default_region}"
      ip_cidr_range            = "10.10.0.0/20"
      region                   = var.default_region
      private_ip_google_access = true
      flow_logs                = false # Set to false to reduce dev logging costs
      secondary_ip_ranges = [
        {
          range_name    = "${var.environment}-pods"
          ip_cidr_range = "10.20.0.0/16"
        },
        {
          range_name    = "${var.environment}-services"
          ip_cidr_range = "10.30.0.0/20"
        }
      ]
    },
    {
      name                     = "${var.environment}-subnet-data-${var.default_region}"
      ip_cidr_range            = "10.10.16.0/20"
      region                   = var.default_region
      private_ip_google_access = true
      flow_logs                = false
      secondary_ip_ranges      = []
    }
  ]

  # Provision Cloud NAT so private instances/nodes can pull container images and packages
  enable_nat  = true
  nat_regions = [var.default_region]

  firewall_rules = [
    {
      name          = "allow-internal"
      description   = "Allow all internal communication across VPC subnets"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["10.10.0.0/16", "10.20.0.0/16", "10.30.0.0/20"]
      allow = [
        { protocol = "icmp" },
        { protocol = "tcp", ports = ["0-65535"] },
        { protocol = "udp", ports = ["0-65535"] }
      ]
    },
    {
      name          = "allow-iap-ssh"
      description   = "Allow inbound SSH via Google Identity-Aware Proxy (IAP)"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["35.235.240.0/20"] # Google Cloud IAP netblock
      target_tags   = ["iap-ssh"]
      allow = [
        { protocol = "tcp", ports = ["22"] }
      ]
    },
    {
      name          = "allow-health-checks"
      description   = "Allow Google Cloud Load Balancer health checks"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["35.191.0.0/16", "130.211.0.0/22"] # Google LB Probers
      target_tags   = ["load-balanced"]
      allow = [
        { protocol = "tcp", ports = ["80", "443", "8080"] }
      ]
    }
  ]
}