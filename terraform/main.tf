terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "commons" {
  source = "./modules/commons"
  project_id = var.project_id
  region = var.region
  iam_bindings = var.iam_bindings
  subnet_1_cidr = var.subnet_1_cidr
  subnet_2_cidr = var.subnet_2_cidr
  composer_node_count = var.composer_node_count
  composer_image_version = var.composer_image_version
  composer_members = var.composer_members
}

module "vendor" {
  source = "./modules/vendor"
  project_id = var.project_id
  region = var.region
  function_runtime = var.function_runtime
  function_entry_point = var.function_entry_point
}
