#remove following code if failed --
terraform {
  backend "gcs" {
    bucket  = "your-bucket-name"
    prefix  = "terraform/state/vendor"
    project = "your-project-id"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "vendor_topic" {
  name    = "vendor-topic"
  project = var.project_id
}

resource "google_storage_bucket" "vendor_bucket" {
  name          = "vendor-bucket-${var.project_id}"
  location      = var.region
  force_destroy = true
  project       = var.project_id
}
# Upload a file to the GCS bucket
resource "google_storage_bucket_object" "my_object" {
  name   = "function-source.zip"  # Name of the file in the bucket
  bucket = google_storage_bucket.vendor_bucket.name
  source = "function-source.zip"  # Path to the local file to upload
}

resource "google_cloudfunctions_function" "vendor_function" {
  name        = "vendor-function"
  runtime     = "python39"  # Use a valid Python runtime version
  entry_point = "hello_pubsub"
  source_archive_bucket = google_storage_bucket.vendor_bucket.name
  source_archive_object = "function-source.zip"
  project               = var.project_id
  service_account_email = "cicd-gcp-appengine@cicd-gcp-424408.iam.gserviceaccount.com"  # Specify your service account

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.vendor_topic.name
  }
}

resource "google_project_iam_binding" "cloudfunctions_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}

resource "google_project_iam_binding" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}

resource "google_project_iam_binding" "artifactregistry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}

resource "google_project_iam_binding" "storage_object_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${var.service_account_email}"
  ]
}
