variable "region" {
  description = "The GCP region to deploy regional resources into [Default = us-central]"
  type        = string
  default     = "us-central1"
}

variable "browser-cache-ttl" {
  description = "The TTL on device (in seconds) for dynamic content being served from the global cache"
  type        = number
  default     = 300
}

variable "cdn-cache-ttl" {
  description = "The TTL on server (in seconds) for dynamic content being served from the global cache"
  type        = number
  default     = 3600
}

variable "cloud-run-max-scale" {
  description = "The maximum number of instances the backend Cloud Run service can scale up to"
  type        = number
  default     = 1000
}