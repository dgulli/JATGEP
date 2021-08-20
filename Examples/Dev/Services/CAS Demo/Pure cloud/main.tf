#Please check your permissions before you execute this - you will need to do slightly more than whats in the doco
## to run this, you will need CA Service Operator and Project IAM rights
### example variables in repo
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
#GCP CAS

## Root CA pool
resource "google_privateca_ca_pool" "ca_pool" {
  name     = var.caPoolName
  location = var.region
  tier     = var.caTier
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
}
## Subordinate CA pool
resource "google_privateca_ca_pool" "subca_pool" {
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
## rootCA 
resource "google_privateca_certificate_authority" "rootca" {
  location                 = var.region
  certificate_authority_id = var.caId
  pool                     = google_privateca_ca_pool.ca_pool.name
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
## sub CA
resource "google_privateca_certificate_authority" "subca" {
  location                 = var.region
  certificate_authority_id = var.subCaId
  pool                     = google_privateca_ca_pool.subca_pool.name
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