resource "google_storage_bucket" "dev_test" {
  name     = "${var.project_id}-dev-test"
  location = var.region

  uniform_bucket_level_access = true

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

# destroying resources created through terraform