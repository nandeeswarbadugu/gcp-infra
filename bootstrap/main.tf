terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
        source = "hashicorp/google"
        version = "~> 8.2"
    }
  }
}

provider "google" {
    project = var.project_id
    region = var.region
}

resource "google_storage_bucket" "terraform_state" {
    name = "${var.project_id}-terraform-state"
    location = var.region

    uniform_bucket_level_access = true

    versioning {
      enabled = true
    }

    lifecycle_rule {
      condition {
        age = 30
      }

      action {
        type = "Delete"
      }
    }

    labels = {
      purpose = "terraform-state"
      managed_by = "terraform"
    }
  
}

