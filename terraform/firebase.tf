resource "google_app_engine_application" "firestore" {

  location_id   = local.formatted_region
  database_type = "CLOUD_FIRESTORE"
}

resource "google_firebase_project" "this" {
  provider = google-beta

  project = data.google_project.this.project_id

  depends_on = [google_app_engine_application.firestore]
}

resource "google_firebase_project_location" "this" {
  provider = google-beta

  project     = google_firebase_project.this.project
  location_id = google_app_engine_application.firestore.location_id
}

resource "google_firebase_web_app" "this" {
  provider = google-beta

  project      = google_firebase_project_location.this.project
  display_name = "TTS-Web-App"
}

data "google_firebase_web_app_config" "this" {
  provider = google-beta

  web_app_id = google_firebase_web_app.this.app_id
}

resource "local_file" "firebase_json" {

  content = templatefile("${path.module}/templates/firebase.json.tftpl", {
    rewrite_config = jsonencode([
      {
        "source" : "/api/**",
        "run" : {
          "serviceId" : google_cloud_run_service.this.name,
          "region" : google_cloud_run_service.this.location
        }
      }
    ])
  })
  filename = "${local.root_dir}/firebase.json"
}

resource "local_file" "firebase_rc" {

  content = templatefile("${path.module}/templates/.firebaserc.tftpl", {
    PROJECT_ID = google_firebase_project.this.project
  })

  filename = "${local.root_dir}/.firebaserc"
}

locals {
  vue_env_vars = {
    FIREBASE_CONFIG = jsonencode(local.web_app_config),
  }
}

resource "local_file" "env" {

  content = <<-EOF
  %{for k, v in local.vue_env_vars~}
  VUE_APP_${k}='${v}'
  %{endfor~}
  EOF

  filename = "${local.root_dir}/front-end/.env"
}

data "archive_file" "front_end" {

  type        = "zip"
  source_dir  = "${local.root_dir}/front-end"
  output_path = "${local.root_dir}/front-end.zip"

  depends_on = [
    local_file.firebase_json,
    local_file.firebase_rc,
    local_file.env,
  ]
}

resource "null_resource" "build_web_app" {

  triggers = {
    source = data.archive_file.front_end.output_sha
  }

  provisioner "local-exec" {
    working_dir = "${local.root_dir}/front-end"
    command     = "npm install --save"
  }

  provisioner "local-exec" {
    working_dir = "${local.root_dir}/front-end"
    command     = "npm run build"
  }

  depends_on = [data.archive_file.front_end]
}

resource "null_resource" "deploy_web_app" {

  triggers = null_resource.build_web_app.triggers

  provisioner "local-exec" {
    working_dir = local.root_dir
    command     = "firebase deploy"

    environment = {
      "FIREBASE_TOKEN" = "${data.google_client_config.current.access_token}"
    }
  }

  depends_on = [null_resource.build_web_app]
}