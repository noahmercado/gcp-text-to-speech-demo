# Google Cloud Text-To-Speach Utility
This repository contains the source code for a GCP Text-To-Speach (TTS) Web App hosted on GCP + Firebase.

## Services
- Firebase Hosting (Global CDN + Cloud Storage)
- Firestore
- Firebase Auth
- Cloud Storage
- Cloud Run
- Text-To-Speech

## Required permissions to deploy
- `roles/editor`
  
## Dependencies

- `terraform >= 1.0.0`
- `gcloud cli >= 385.0.0`
- `gsutil cli >= 5.10`
- `firebase cli >= 10.4.2`
- `nodejs >= v18.1.0`
- `npm >= 8.8.0`
- `curl >= 7.79.1`

## Architecture 
![ARCHITECTURE](./assets/TTS-Web-App.drawio.png "Architecture")  
  
    
## How to deploy
```bash
# Clone repo 

cd gcp-text-to-speech-demo

# Review the default configuration in variables.tfvars and modify as needed

# Log in to gcloud cli 
gcloud auth login

# Configure your CLI to point to the GCP project you want to deploy into
gcloud config set project ${YOUR_GCP_PROJECT_ID}

# Prepare the GCP project
make tf-backend

# Deploy the web App
make app

# Optional cleanup of any remaining artifacts
make clean

```