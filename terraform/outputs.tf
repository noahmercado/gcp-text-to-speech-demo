output "web_app" {
    description = "Instructions on how to access web app"
    value = <<-EOT

    Your web app has been deployed to ${data.google_project.this.project_id}.firebaseapp.com

    EOT
}