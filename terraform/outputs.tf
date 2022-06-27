output "web_app" {
  description = "Instructions on how to access web application"
  value       = <<-EOT

    Your web app has successfully been deployed to ${data.google_project.this.project_id}.firebaseapp.com

    Please make sure to naviate to https://console.firebase.google.com/u/0/project/${data.google_project.this.project_id}/authentication/providers and enable the "Anonymous" Sign-in provider in order for your web application work.

    EOT
}