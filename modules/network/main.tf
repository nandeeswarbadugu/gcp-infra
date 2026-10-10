# --- VPC Network ---
resource "google_compute_network" "vpc" {
  name                            = var.network_name
  project                         = var.project_id
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

# --- Subnets ---
resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                     = each.value.name
  ip_cidr_range            = each.value.ip_cidr_range
  region                   = each.value.region
  network                  = google_compute_network.vpc.id
  project                  = var.project_id
  private_ip_google_access = each.value.private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = each.value.flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

# --- Cloud Router & NAT (Optional) ---
resource "google_compute_router" "router" {
  for_each = var.enable_nat ? toset(var.nat_regions) : []

  name    = "${var.network_name}-router-${each.key}"
  region  = each.key
  network = google_compute_network.vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  for_each = var.enable_nat ? toset(var.nat_regions) : []

  name                               = "${var.network_name}-nat-${each.key}"
  router                             = google_compute_router.router[each.key].name
  region                             = each.key
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# --- Custom Firewall Rules ---
resource "google_compute_firewall" "rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name                    = "${var.network_name}-${each.value.name}"
  network                 = google_compute_network.vpc.name
  project                 = var.project_id
  direction               = each.value.direction
  priority                = each.value.priority
  source_ranges           = length(each.value.source_ranges) > 0 ? each.value.source_ranges : null
  source_tags             = length(each.value.source_tags) > 0 ? each.value.source_tags : null
  target_tags             = length(each.value.target_tags) > 0 ? each.value.target_tags : null
  target_service_accounts = length(each.value.target_service_accounts) > 0 ? each.value.target_service_accounts : null

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = length(allow.value.ports) > 0 ? allow.value.ports : null
    }
  }
}