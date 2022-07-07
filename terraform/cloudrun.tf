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
    command     = "gcloud builds submit --region=${var.region} --tag ${local.container_image} --project ${local.project_id}"
  }
}

resource "google_cloud_run_service" "this" {

  name     = "tts-backend"
  location = var.region

  template {
    spec {
      containers {
        image = local.container_image
        env {
          name  = "GCS_BUCKET_NAME"
          value = local.web_app_config["storageBucket"]
        }

        env {
          name  = "FIREBASE_DOMAINS"
          value = join(",", local.firebase_domains)
        }

        env {
          name  = "BROWSER_CACHE_TTL"
          value = var.browser-cache-ttl
        }

        env {
          name  = "CDN_CACHE_TTL"
          value = var.cdn-cache-ttl
        }

      }
      service_account_name = google_service_account.tts_web_app.email
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = tostring(var.cloud-run-max-scale)
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
