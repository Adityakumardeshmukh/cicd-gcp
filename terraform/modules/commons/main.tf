provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_iam_binding" "common_bindings" {
  project = var.project_id
  role    = "roles/editor"
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}

resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "subnet-1"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "subnet-2"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
  region        = var.region
}

module "composer" {
  source  = "terraform-google-modules/composer/google"
  version = "~> 0.1"
  name    = "composer-cluster"
  region  = var.region
  network = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.subnet_1.self_link
}
