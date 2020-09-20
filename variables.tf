variable "project" {
  description = "Name of your Google Cloud project."
  type = string
}

variable "region" {
  description = "The region which the Google Cloud resources will be created in."
  type = string
}

variable "location" {
  description = "The location which the Google Cloud resources will be created in."
  type = string
}

variable "labels" {
  description = "Labels your Google Cloud resources should be labeled with."
  type = map
  default = {}
}

variable "service_account" {
  description = "The Google Cloud service account which will download the videos from the input bucket, will run the function to transcode the video and upload it to the output bucket."
  type = string
}

variable "video_input_bucket" {
  description = "Name of the Google Cloud Storage bucket which you will upload the original videos to."
  type = string
}

variable "video_output_bucket" {
  description = "Name of the Google Cloud Storage bucket which the transcoded videos will be served from."
  type = string
}

variable "function_sources_bucket" {
  description = "Name of the Google Cloud Storage bucket which the source code for the Google Cloud Function will be hosted in."
  type = string
}

variable "function_name" {
  description = "Name of the Google Cloud Function which will do the video transcoding."
  type = string
}

variable "func_cdn_base_url" {
  description = "" // TODO: Add description
  type = string
  default = ""
}

variable "func_mailgun_domain_name" {
  description = "Mailgun domain which will be used to send the success notification email."
  type = string
  default = ""
}

variable "func_mailgun_api_key" {
  description = "API key of your Mailgun domain which will be used to send the success notification email."
  type = string
  default = ""
}

variable "func_mail_receiver" {
  description = "Email address the success notification should be send to."
  type = string
  default = ""
}
