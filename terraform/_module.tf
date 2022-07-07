terraform {
  required_providers {
    google = {
      version = "~> 4.26.0"
      source  = "hashicorp/google"
    }

    google-beta = {
      version = "~> 4.26.0"
      source  = "hashicorp/google-beta"
    }
    local = {
      version = "~> 2.2.3"
      source  = "hashicorp/local"
    }
    archive = {
      version = "~> 2.2.0"
      source  = "hashicorp/archive"
    }
    null = {
      version = "~> 3.1.1"
      source  = "hashicorp/null"
    }
  }
  required_version = ">= 1.0.0"
}

locals {
  migration_plan        = yamldecode(file("ledgermonolith-migration.yaml"))
  migration_spec        = local.migration_plan["spec"]
  merged_spec           = merge(local.migration_spec, { "dataVolumes" = [{ "folders" = ["/var/lib/postgresql"] }] })
  merged_migration_plan = merge({ "spec" = local.merged_spec }, { for k, v in local.migration_plan : k => v if k != "spec" })
}