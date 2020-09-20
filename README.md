<h1 align="center">Video transcoding and serving via Google Cloud</h1>

<div align="center">
  <p><strong>Terraform Module to transcode and serve videos via Google Cloud services.</strong></p>

  <p>Uses ffmpeg running on Google Cloud Functions for the transcoding process.</p>

  <hr>

  <p><em>work in progress</em></p>
</div>

## Overview

[]([./.github/assets/](https://github.com/simonknittel/terraform-google-video-transcoding/tree/master/.github/asstes/terraform-google-video-transcoding.svg))

## Usage

1. Duplicate `sample.tfvars` to `prod.tfvars` or similar
2. Modify the Terraform variables in `prod.tfvars` to your needs
3. Run `terraform apply -var-file prod.tfvars`
