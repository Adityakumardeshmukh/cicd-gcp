// Apply necessary IAM bindings
resource "google_project_iam_member" "bindings" {
  for_each = var.iam_bindings
  project  = var.project_id
  role     = each.value.role
  member   = each.value.member
}

// Create VPC with two subnets
resource "google_compute_network" "vpc_network" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "${var.project_id}-subnet-dags"
  ip_cidr_range = var.subnet_1_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.name
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "${var.project_id}-subnet-composer"
  ip_cidr_range = var.subnet_2_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.name
}

// Create Composer cluster
resource "google_composer_environment" "composer" {
  name   = "${var.project_id}-composer"
  region = var.region
  config {
    node_count = var.composer_node_count
    software_config {
      image_version = var.composer_image_version
    }
  }
}

// Implement cluster role binding
resource "google_project_iam_binding" "composer_binding" {
  project = var.project_id
  role    = "roles/composer.user"
  members = var.composer_members
}
