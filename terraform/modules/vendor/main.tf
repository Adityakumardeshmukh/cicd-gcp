#remove following code if failed --
terraform {
  backend "gcs" {
    bucket  = "cicd-gcp-tfstate"
    prefix  = "terraform/state/vendor"
    #project = "cicd-gcp-424408"
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
resource "google_storage_notification" "notification_1" {
  bucket = google_storage_bucket.vendor_bucket.name
  payload_format = "JSON_API_V1"
  topic = google_pubsub_topic.vendor_topic.id
  event_types = [
    "OBJECT_FINALIZE",
  ]
  
}
# Data block to create a zip file
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/cloud_function"
  output_path = "${path.module}/cloud_function/function-source.zip"
}

# Upload the zip file to the GCS bucket
resource "google_storage_bucket_object" "my_object" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.vendor_bucket.name
  source = data.archive_file.function_zip.output_path
}

# BigQuery Dataset
resource "google_bigquery_dataset" "my_dataset" {
  dataset_id = "db_demo_1"
  project    = var.project_id
  location   = var.region
}

# BigQuery Table
resource "google_bigquery_table" "my_table" {
  dataset_id = google_bigquery_dataset.my_dataset.dataset_id
  table_id   = "table_demo_1"
  project    = var.project_id
}
# Cloud Function
resource "google_cloudfunctions_function" "vendor_function" {
  name        = "function_demo_1"
  runtime     = "python39"
  entry_point = "hello_pubsub"
  source_archive_bucket = google_storage_bucket.vendor_bucket.name
  source_archive_object = google_storage_bucket_object.my_object.name
  project               = var.project_id
  service_account_email = "cicd-gcp-appengine@cicd-gcp-424408.iam.gserviceaccount.com"

  environment_variables = {
    project_id    = var.project_id
    dataset_id    = google_bigquery_dataset.my_dataset.dataset_id  # Replace with your dataset
    table_id      = google_bigquery_table.my_table.table_id    # Replace with your table
  }

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.vendor_topic.name
  }
}

# resource "google_project_iam_binding" "cloudfunctions_invoker" {
#   project = var.project_id
#   role    = "roles/cloudfunctions.invoker"
#   members = [
#     "serviceAccount:${var.service_account_email}"
#   ]
# }

# resource "google_project_iam_binding" "pubsub_publisher" {
#   project = var.project_id
#   role    = "roles/pubsub.publisher"
#   members = [
#     "serviceAccount:${var.service_account_email}"
#   ]
# }

# resource "google_project_iam_binding" "storage_admin" {
#   project = var.project_id
#   role    = "roles/storage.admin"
#   members = [
#     "serviceAccount:${var.service_account_email}"
#   ]
# }

# resource "google_project_iam_binding" "artifactregistry_reader" {
#   project = var.project_id
#   role    = "roles/artifactregistry.reader"
#   members = [
#     "serviceAccount:${var.service_account_email}"
#   ]
# }

# resource "google_project_iam_binding" "storage_object_viewer" {
#   project = var.project_id
#   role    = "roles/storage.objectViewer"
#   members = [
#     "serviceAccount:${var.service_account_email}"
#   ]
# }
