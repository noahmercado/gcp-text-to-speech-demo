locals {
  backend_config = yamldecode(file("${local.root_dir}/config/.backend.lock.yml"))

  formatted_region = var.region == "us-central1" || var.region == "europe-west1" ? substr(var.region, 0, length(var.region) - 1) : var.region

  root_dir = dirname(abspath(path.module))

  container_image = "gcr.io/${data.google_project.this.project_id}/tts-web-app:${data.archive_file.service.output_sha}"
  access_token    = data.google_client_config.current.access_token
  project_id      = data.google_project.this.project_id

  web_app_config = sensitive({
    appId             = google_firebase_web_app.this.app_id
    apiKey            = data.google_firebase_web_app_config.this.api_key
    authDomain        = data.google_firebase_web_app_config.this.auth_domain
    projectId         = google_firebase_project.this.project
    databaseURL       = lookup(data.google_firebase_web_app_config.this, "database_url", "")
    storageBucket     = lookup(data.google_firebase_web_app_config.this, "storage_bucket", "")
    messagingSenderId = lookup(data.google_firebase_web_app_config.this, "messaging_sender_id", "")
    measurementId     = lookup(data.google_firebase_web_app_config.this, "measurement_id", "")
  })

}
