
terraform {
  backend "gcs" {
    bucket = "project-9e7b2f42-382b-4a9d-ab6-terraform-state"
    prefix = "terraform/dev"
  }
}