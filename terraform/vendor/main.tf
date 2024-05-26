// Create Cloud Function
resource "google_cloudfunctions_function" "function" {
  name        = "${var.project_id}-function"
  runtime     = var.function_runtime
  entry_point = var.function_entry_point
  source_archive_bucket = google_storage_bucket.function_source_bucket.name
  source_archive_object = google_storage_bucket_object.function_source_archive.name
  trigger_http = false
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.topic.id
  }
}

// Create Pub/Sub topic
resource "google_pubsub_topic" "topic" {
  name = "${var.project_id}-topic"
}

// Create Vendor Bucket
resource "google_storage_bucket" "vendor_bucket" {
  name     = "${var.project_id}-vendor-bucket"
  location = var.region
}

resource "google_storage_bucket_notification" "bucket_notification" {
  bucket = google_storage_bucket.vendor_bucket.name
  topic  = google_pubsub_topic.topic.id
  event_types = ["OBJECT_FINALIZE"]
  payload_format = "JSON_API_V1"
  object_name_prefix = "landing/"
}

resource "google_storage_bucket_object" "function_source_archive" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.function_source_bucket.name
  source = "path/to/function/source.zip"
}

resource "google_storage_bucket" "function_source_bucket" {
  name     = "${var.project_id}-function-source"
  location = var.region
}
