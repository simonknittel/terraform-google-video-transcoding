# Simple example

Minimal setup:

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
