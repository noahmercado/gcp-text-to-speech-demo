resource "google_service_account" "tts_web_app" {
  account_id   = "tts-web-app"
  display_name = "Text-to-Speech Web App SA"
}

resource "google_project_iam_member" "tts_web_app" {
  for_each = toset(["roles/editor"])

  project = local.backend_config["project"]
  role    = each.value
  member  = "serviceAccount:${google_service_account.tts_web_app.email}"
}

data "archive_file" "service" {

  type        = "zip"
  source_dir  = "${local.root_dir}/app"
  output_path = "${local.root_dir}/tts-web-app.zip"
}

resource "null_resource" "build_image" {

  triggers = {
    sha = local.container_image
  }

  provisioner "local-exec" {

    working_dir = "${local.root_dir}/app"
    command     = "gcloud builds submit --region=${var.region} --tag ${local.container_image}"
  }
}

resource "google_cloud_run_service" "this" {

  name     = "tts-backend"
  location = var.region

  template {
    spec {
      containers {
        image = local.container_image
      }
      service_account_name = google_service_account.tts_web_app.email
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "1000"
        "run.googleapis.com/client-name"   = "terraform"
      }
    }
  }

  autogenerate_revision_name = true

  depends_on = [null_resource.build_image]
}

data "google_iam_policy" "noauth" {

  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "service" {

  location = google_cloud_run_service.this.location
  project  = google_cloud_run_service.this.project
  service  = google_cloud_run_service.this.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
