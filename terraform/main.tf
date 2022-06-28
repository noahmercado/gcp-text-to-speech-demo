terraform {
  backend "gcs" {
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
