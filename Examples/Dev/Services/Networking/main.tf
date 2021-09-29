provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
#Setup network
resource "google_compute_network" "default-network" {
  name                    = "test-network"
  auto_create_subnetworks = true
}
resource "google_compute_network" "custom-network" {
  name                    = "custom-network"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet1" {
  name          = "test-subnetwork-sydney"
  ip_cidr_range = "10.2.0.0/16"
  region        = "australia-southeast1"
  network       = google_compute_network.custom-network.id
}
resource "google_compute_subnetwork" "subnet2" {
  name                     = "test-subnetwork-melbourne"
  ip_cidr_range            = "192.168.0.0/16"
  region                   = "australia-southeast2"
  private_ip_google_access = true #access my bucket wthout an external IP
  network                  = google_compute_network.custom-network.id
}
#demo box
resource "google_compute_instance" "vm_instance" {
  name         = var.machineName
  machine_type = var.machineType
  zone = "australia-southeast2-a" #notice that the VM DOES need to be in a zone

  boot_disk {
    initialize_params {
      image = var.machineImage
    }
  }
  network_interface {
    network    = google_compute_network.custom-network.id
    subnetwork = google_compute_subnetwork.subnet2.id
  }
  metadata = {
    startup-script = file(var.machineScript)
    serial-port-enable         = var.machineSerialPortEnabled
  }
}
#IAP setup for the machine
resource "google_compute_firewall" "firewalliap" {
  name          = var.firewallRuleIAPName
  network       = google_compute_network.custom-network.id
  source_ranges = var.firewallSourceRanges
  allow {
    protocol = var.firewallProtocol
    ports    = var.firewallPorts
  }
}
#IAP IAM
data "google_iam_policy" "admin" {
  binding {
    role    = var.iapRole
    members = var.iapMembers
  }
}
resource "google_iap_tunnel_iam_policy" "policy" {
  project     = var.project
  policy_data = data.google_iam_policy.admin.policy_data
}

# GCS bucket for demo
resource "google_storage_bucket" "pefbucket1"{
    name = "pefbucket1"
    location = "EU" #hey look its multi-region!
    force_destroy = "true" #delete the bucket deletes the key pair values inside
}