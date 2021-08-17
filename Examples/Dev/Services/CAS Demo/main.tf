#Please check your permissions before you execute this - you will need to do slightly more than whats in the doco
## to run this, you will need CA Service Operator and Project IAM rights
### example variables in repo
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
#Setup network
resource "google_compute_network" "cas-network" {
  name                    = var.vpc-name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet-name
  ip_cidr_range = var.subnet-CIDR
  region        = var.region
  network       = google_compute_network.cas-network.id
}
#setup vm for root CA
resource "google_compute_instance" "vm_instance" {
  name         = var.machineName
  machine_type = var.machineType

  boot_disk {
    initialize_params {
      image = var.machineImage
    }
  }
  network_interface {
    network    = google_compute_network.cas-network.id
    subnetwork = google_compute_subnetwork.subnet.id
  }
  metadata = {
    startup-script = file(var.machineScript)
    serial-port-enable         = var.machineSerialPortEnabled
  }
}
#IAP setup for root CA machine
resource "google_compute_firewall" "firewalliap" {
  name          = var.firewallRuleIAPName
  network       = google_compute_network.cas-network.id
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
#GCP CAS

## CA pool
resource "google_privateca_ca_pool" "ca_pool" {
  name     = var.caPoolName
  location = var.region
  tier     = var.caTier
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
}
## KMS Permissions for the CA
resource "google_project_service_identity" "privateca_sa" {
  provider = google-beta
  service  = "privateca.googleapis.com"
  project  = var.project
}

resource "google_kms_crypto_key_iam_binding" "privateca_sa_keyuser_signerverifier" {
  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.signerVerifier"

  members = [
    "serviceAccount:${google_project_service_identity.privateca_sa.email}",
  ]
}

resource "google_kms_crypto_key_iam_binding" "privateca_sa_keyuser_viewer" {
  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/viewer"
  members = [
    "serviceAccount:${google_project_service_identity.privateca_sa.email}",
  ]
}
## sub CA
resource "google_privateca_certificate_authority" "subca" {
  location                 = var.region
  certificate_authority_id = var.caId
  pool                     = google_privateca_ca_pool.ca_pool.name
  type                     = var.caType
  config {
    x509_config {
      ca_options {
        is_ca                  = true
        max_issuer_path_length = 10
      }
      key_usage {
        base_key_usage {
          crl_sign  = true
          cert_sign = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = true
          code_signing     = true
          email_protection = false
        }
      }
    }
    subject_config {
      subject {
        organization        = var.subjectOrg
        common_name         = var.subjectCn
        country_code        = var.subjectCc
        organizational_unit = var.subjectOu
        province            = var.subjectProvince
        locality            = var.subjectLocality
      }
    }
  }
  key_spec {
    cloud_kms_key_version = trimprefix(data.google_kms_crypto_key_version.keyVersion.id, "//cloudkms.googleapis.com/v1/")
  }
}
#GCP KMS (PREREQUISITE)
#create a keyring
resource "google_kms_key_ring" "keyring" {
  name     = var.kmsKeyRingName
  location = var.region
}
#create a key
resource "google_kms_crypto_key" "key" {
  name     = var.kmsKeyName
  key_ring = google_kms_key_ring.keyring.id
  purpose  = var.kmsKeyPurpose

  version_template {
    algorithm        = var.kmsKeyAlgo
    protection_level = "HSM"
  }

  lifecycle {
    prevent_destroy = false
  }
}
#KMS Data block for CAS key version input
data "google_kms_crypto_key_version" "keyVersion" {
  crypto_key = google_kms_crypto_key.key.id
}

output "network_id" {
  value = google_compute_network.cas-network.id
}
output "vm_instance_id" {
  value = google_compute_instance.vm_instance.instance_id
}
