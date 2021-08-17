provider "google" {
    project = ""
    region = "us-central1"
    zone = "us-central1-c"
}

resource "google_storage_bucket" "state_bucket"{
    name = ""
    storage_class = "STANDARD"
    versioning {
        enabled="true"
    }
}