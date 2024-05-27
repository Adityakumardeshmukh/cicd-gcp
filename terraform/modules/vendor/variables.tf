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

# Add more variables as needed

# variable "function_runtime" {
#   description = "The runtime environment for the Cloud Function"
#   type        = string
#   default     = "python37"  # Replace with your desired default runtime
# }

# variable "function_entry_point" {
#   description = "The entry point function for the Cloud Function"
#   type        = string
#   default     = "main"  # Replace with your desired default entry point function
# }
