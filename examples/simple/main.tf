terraform {
  backend "remote" {}
}

module "video-transcoding" {
  source = "../../"

  project = var.project
  region = var.region
  location = var.location
  service_account = var.service_account

  video_input_bucket = var.video_input_bucket
  video_output_bucket = var.video_output_bucket
  function_sources_bucket = var.function_sources_bucket
  function_name = var.function_name
}
