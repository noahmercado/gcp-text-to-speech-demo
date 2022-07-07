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