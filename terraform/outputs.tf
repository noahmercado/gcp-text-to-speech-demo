output "web_app" {
  description = "Instructions on how to access web application"
  value       = <<-EOT

    Your web app has successfully been deployed to https://${data.google_project.this.project_id}.firebaseapp.com

    Please make sure to navigate to https://console.firebase.google.com/u/0/project/${data.google_project.this.project_id}/authentication/providers to ensure that the "Anonymous" Sign-in provider has properly been enabled. If it is still disabled, please enable it in order for your web application to properly work.

    EOT
}