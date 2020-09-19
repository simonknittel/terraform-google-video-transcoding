terraform {
  backend "remote" {
    organization = "simonknittel"

    workspaces {
      name = "gcloud-video-transcoding"
    }
  }
}

variable "project" {
  type = string
  description = "Name of your Google Cloud project."
}

variable "region" {
  type = string
  description = "The region which the Google Cloud resource will be created in."
}

variable "location" {
  type = string
  description = "The location which the Google Cloud resource will be created in."
}

variable "service_account" {
  type = string
  description = "The Google Cloud service account which will download the videos from the input bucket, will run the function to transcode the video and upload it to the output bucket."
}

variable "video_input_bucket" {
  type = string
  description = "Name of the Google Cloud Storage bucket which you will upload videos to."
}

variable "video_output_bucket" {
  type = string
  description = "Name of the Google Cloud Storage bucket which the transcoded videos will be served from."
}

variable "function_sources_bucket" {
  type = string
  description = "Name of the Google Cloud Storage bucket which the source code for the Google Cloud Function will be hosted in."
}

variable "function_name" {
  type = string
  description = "Name of the Google Cloud Function which will do the video transcoding."
}

variable "func_cdn_base_url" { type = string } // TODO: Add description

variable "func_mailgun_domain_name" {
  type = string
  default = ""
  description = "Mailgun domain which will be used to send the success notification email."
}

variable "func_mailgun_api_key" {
  type = string
  default = ""
  description = "API key of your Mailgun domain which will be used to send the success notification email."
}

variable "func_mail_receiver" {
  type = string
  default = ""
  description = "Email address the success notification should be send to."
}

provider "google" {
  project = var.project
  region = var.region
}

resource "google_storage_bucket" "input" {
  name = var.video_input_bucket
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
  name = var.video_output_bucket
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
  name = var.function_sources_bucket
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
  name = var.function_name
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
    MAILGUN_DOMAIN_NAME = var.func_mailgun_domain_name
    MAILGUN_API_KEY = var.func_mailgun_api_key
    MAIL_RECEIVER = var.func_mail_receiver
    CDN_BASE_URL = var.func_cdn_base_url
  }
}

resource "google_cloudfunctions_function_iam_member" "sa_invoker" {
  cloud_function = google_cloudfunctions_function.transcode_python.name
  role = "roles/cloudfunctions.invoker"
  member = var.service_account
}

// TODO: Add Terraform config for Load Balancer and CDN
