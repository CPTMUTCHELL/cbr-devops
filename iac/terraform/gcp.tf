variable "project-id" {}
variable "terraform-sa" {}
variable "region" {}
variable "zone" {}
variable "gcp-user" {}

variable "gcp_service_list" {
  description ="The list of apis necessary for the project"
  type = list(string)
  default = [
    "compute.googleapis.com",
    "dns.googleapis.com"
    # https://github.com/hashicorp/terraform-provider-google/issues/6101
  ]
}

provider "google" {
  credentials = file(var.terraform-sa)
  project     = var.project-id
  region      = var.region
  zone        = var.zone

}


resource "google_compute_address" "static" {
  name = "external-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  project = var.project-id
}


resource "google_project_service" "enable-apis" {
  for_each = toset(var.gcp_service_list)
  project = var.project-id
  service = each.key

}
