terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.74.0"
    }
  }
}

provider "google" {
    project = var.project
    region = var.region
    zone = var.zone
}
resource "google_project_organization_policy" "serial_port_policy" {
  project    = var.projectID
  constraint = "compute.disableSerialPortAccess"

  boolean_policy {
    enforced = true
  }
}