variable "ssh-key-jenkins-instance" {}
resource "google_compute_address" "static-address-jenkins" {
  name = "external-ip-jenkins"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  project = var.project-id
}

resource "google_compute_instance" "jenkins-instance" {
  name = "jenkins-instance"
  machine_type = "e2-medium"
  tags = ["allow-http","allow-https","http-server","https-server","jenkins-port"]
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20230302"
      size = 40
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static-address-jenkins.address
    }
  }
  depends_on = [google_project_service.enable-apis]

  metadata = {
    sshKeys = "${var.gcp-user}:${file(var.ssh-key-jenkins-instance)}"
  }
}

resource "google_compute_firewall" "jenkins-rules" {
  name = "jenkins"
  priority = 1000
  allow {
    protocol = "tcp"
    ports = ["8080"]
  }
  network = "default"
  target_tags = ["jenkins-port"]
  source_ranges = ["0.0.0.0/0"]

}

# terraform output jenkins-ip
output "jenkins-ip" {
  value = google_compute_address.static-address-jenkins.address
}