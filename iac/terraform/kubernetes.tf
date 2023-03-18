variable "ssh-key-kubernetes-instance" {}
variable "dns" {}
variable "subdomain" {}

resource "google_compute_instance" "kubernetes-instance" {
  name = "kubernetes-instance"
  machine_type = "e2-medium"
  tags = ["allow-http","allow-https","http-server","https-server","kubernetes-port"]
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20230302"
      size = 30
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  depends_on = [google_project_service.enable-apis]

  metadata = {
    sshKeys = "${var.gcp-user}:${file(var.ssh-key-kubernetes-instance)}"
  }
}
resource "google_compute_firewall" "kubernetes-rules" {
  name = "kubernetes"
  priority = 1000
  allow {
    protocol = "tcp"
    ports = ["6443"]
  }
  network = "default"
  target_tags = ["kubernetes-port"]
  source_ranges = ["0.0.0.0/0"]

}

resource "google_dns_managed_zone" "cluster-zone" {
  depends_on = [google_project_service.enable-apis]

  name        = "cluster-zone"
  dns_name    = "${var.dns}."

}
resource "google_dns_record_set" "a-record" {
  name = "${var.subdomain}${google_dns_managed_zone.cluster-zone.dns_name}"
  type = "A"
  ttl  = 300
  managed_zone = google_dns_managed_zone.cluster-zone.name
  rrdatas = [google_compute_instance.kubernetes-instance.network_interface[0].access_config[0].nat_ip]
}


# terraform output cluster-ip
output "cluster-ip" {
  value = google_compute_address.static.address
}