# Simple example

Simple setup with remote backend and the use of a .tfvars file for the variables.

```tf
# main.tf

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
```

```tf
# variables.tf

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "location" {
  type = string
}

variable "service_account" {
  type = string
}

variable "video_input_bucket" {
  type = string
}

variable "video_output_bucket" {
  type = string
}

variable "function_sources_bucket" {
  type = string
}

variable "function_name" {
  type = string
}
```

```tfvars
# sample.tfvars

project = ""
region = "europe-west3"
location = "EUROPE-WEST3"
service_account = "serviceAccount:???@???.iam.gserviceaccount.com"

video_input_bucket = ""
video_output_bucket = ""
function_sources_bucket = ""
function_name = ""
```

```hcl
# backend.hcl

organization = ""

workspaces {
  name = ""
}
```
