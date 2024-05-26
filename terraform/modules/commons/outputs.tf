output "vpc_network" {
  value = google_compute_network.vpc_network.name
}

output "subnet_1" {
  value = google_compute_subnetwork.subnet_1.name
}

output "subnet_2" {
  value = google_compute_subnetwork.subnet_2.name
}

output "composer_environment" {
  value = google_composer_environment.composer.name
}
