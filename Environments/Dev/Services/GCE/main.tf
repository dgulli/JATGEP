//Configure Provider
provider "google" {
    project = "terrraformpoc"
    region = "us-central1"
    zone = "us-central1-c"
}

resource "google_compute_instance" "vm_instance" {
    name = "terraform-instance"
    machine_type = "f1-micro"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-9"
        }
    }
    network_interface {
        network = "default"
        access_config {
            
        }
    }
}
output "vm_instance_id" {
    value = "${google_compute_instance.vm_instance.instance_id}"
}

