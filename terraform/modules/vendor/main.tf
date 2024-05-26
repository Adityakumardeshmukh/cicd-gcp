resource "google_pubsub_topic" "vendor_topic" {
  name = "vendor-topic"
}

resource "google_storage_bucket" "vendor_bucket" {
  name          = "vendor-bucket-${var.project_id}"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_notification" "bucket_notification" {
  bucket = google_storage_bucket.vendor_bucket.name
  topic  = google_pubsub_topic.vendor_topic.id
  event_types = ["OBJECT_FINALIZE"]

  payload_format = "JSON_API_V1"
}

resource "google_cloudfunctions_function" "vendor_function" {
  name        = "vendor-function"
  runtime     = "python37"
  entry_point = "main"
  source_archive_bucket = google_storage_bucket.vendor_bucket.name
  source_archive_object = "vendor_function.zip"
  trigger_http = false
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.vendor_topic.id
  }
}
