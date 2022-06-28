# The region to deploy regional resources into 
region = "us-central1" 

# The TTL on device (in seconds) for dynamic content being served from the global cache
browser-cache-ttl = 300 

# The TTL on server (in seconds) for dynamic content being served from the global cache
cdn-cache-ttl = 14400

# The maximum number of instances the backend Cloud Run service can scale up to
cloud-run-max-scale = 1000