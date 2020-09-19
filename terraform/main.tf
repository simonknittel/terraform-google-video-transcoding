variable "project" { type = string }
variable "region" { type = string }
variable "location" { type = string }
variable "service_account" { type = string }
variable "env_mailgun_api_key" { type = string }
variable "env_mailgun_domain_name" { type = string }
variable "env_mail_receiver" { type = string }
variable "env_cdn_base_url" { type = string }

provider "google" {
  project = var.project
  region = var.region
}

resource "google_storage_bucket" "input" {
  name = "sk-video-transcoding-input-beta"
  location = var.location

  uniform_bucket_level_access = true

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age = 1
    }
  }
}

resource "google_storage_bucket_iam_member" "sa_viewer" {
  bucket = google_storage_bucket.input.name
  role = "roles/storage.objectViewer"
  member = var.service_account
}

resource "google_storage_bucket" "output" {
  name = "sk-video-transcoding-output-beta"
  location = var.location

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "sa_creator" {
  bucket = google_storage_bucket.output.name
  role = "roles/storage.objectCreator"
  member = var.service_account
}

resource "google_storage_bucket_iam_member" "public_viewer" {
  bucket = google_storage_bucket.output.name
  role = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket" "sources" {
  name = "sk-video-transcoding-sources-beta"
  location = var.location
}

data "archive_file" "transcode_python" {
  type = "zip"
  source_dir = "../functions/transcode-python"
  output_path = "../functions/transcode-python.zip"
}

resource "google_storage_bucket_object" "transcode_python" {
  name = "transcode-python.zip"
  source = data.archive_file.transcode_python.output_path
  bucket = google_storage_bucket.sources.name
}

resource "google_cloudfunctions_function" "transcode_python" {
  name = "transcode-python-beta"
  runtime = "python37"

  available_memory_mb = 512
  timeout = 120
  entry_point = "main"
  max_instances = 1
  ingress_settings = "ALLOW_INTERNAL_ONLY"

  source_archive_bucket = google_storage_bucket.sources.name
  source_archive_object = google_storage_bucket_object.transcode_python.name

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource = google_storage_bucket.input.name
  }

  environment_variables = {
    INPUT_BUCKET = google_storage_bucket.input.name
    OUTPUT_BUCKET = google_storage_bucket.output.name
    MAILGUN_API_KEY = var.env_mailgun_api_key
    MAILGUN_DOMAIN_NAME = var.env_mailgun_domain_name
    MAIL_RECEIVER = var.env_mail_receiver
    CDN_BASE_URL = var.env_cdn_base_url
  }
}

resource "google_cloudfunctions_function_iam_member" "sa_invoker" {
  cloud_function = google_cloudfunctions_function.transcode_python.name
  role = "roles/cloudfunctions.invoker"
  member = var.service_account
}
