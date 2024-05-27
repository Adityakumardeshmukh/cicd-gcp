variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "cicd-gcp-424408"  # Replace with your actual project ID
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"  # Replace with your desired default region
}

variable "service_account_email" {
  description = "The service account email"
  type        = string
  default     = "cicd-gcp-service-account@cicd-gcp-424408.iam.gserviceaccount.com"  # Replace with your actual service account email
}
