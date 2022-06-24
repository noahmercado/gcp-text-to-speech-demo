terraform {
  backend "gcs" {
    bucket = "tts-utility-354320-tf-backend-4029"
    prefix = "terraform/modules/tts-web-app/state"
  }
}

provider "google" {

  region                      = var.region
  project                     = local.backend_config["project"]
  impersonate_service_account = local.backend_config["serviceAccount"]
}

provider "google-beta" {

  region                      = var.region
  project                     = local.backend_config["project"]
  impersonate_service_account = local.backend_config["serviceAccount"]
}
