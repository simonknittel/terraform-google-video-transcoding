<h1 align="center">Video transcoding and serving via Google Cloud</h1>

<div align="center">
  <p><strong>Terraform Module to transcode and serve videos via Google Cloud services.</strong></p>

  <p>Uses ffmpeg running on Google Cloud Functions for the transcoding process.</p>

  <hr>

  <p><em>work in progress</em></p>
</div>

<div align="center">
  <img src="https://raw.githubusercontent.com/simonknittel/terraform-google-video-transcoding/master/.github/assets/terraform-google-video-transcoding.svg">
</div>

## Usage

Minimal setup:

1. Create a Google Cloud project and service account
2. Add the module to your main.tf
3. Adjust the variables of the module to your needs

```tf
# main.tf

module "video-transcoding" {
  source = "simonknittel/video-transcoding/google"
  version = "0.1.0"

  project = ""
  region = "europe-west3"
  location = "EUROPE-WEST3"
  service_account = "serviceAccount:???@???.iam.gserviceaccount.com"

  video_input_bucket = ""
  video_output_bucket = ""
  function_sources_bucket = ""
  function_name = ""
}
```

See [examples directory](./examples/) for more examples.
