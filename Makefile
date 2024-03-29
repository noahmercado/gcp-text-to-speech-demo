BACKEND_BUCKET:=$$(grep 'bucket:' ./config/.backend.lock.yml | cut -d ':' -f 2 | tr -d '"' | tr -d '[:space:]')
SERVICE_ACCOUNT:=$$(grep 'serviceAccount:' ./config/.backend.lock.yml | cut -d ':' -f 2 | tr -d '"' | tr -d '[:space:]')

app: check init validate plan apply
update: check plan apply

.PHONY: check
check:
	@command -v terraform >/dev/null || ( echo "Terraform is not installed!"; exit 1)
	@command -v gcloud >/dev/null || ( echo "gcloud CLI is not installed!"; exit 1)
	@command -v npm >/dev/null || ( echo "npm is not installed!"; exit 1)
	@command -v gsutil >/dev/null || ( echo "gsutil CLI is not installed!"; exit 1)
	@command -v curl >/dev/null || ( echo "curl is not installed!"; exit 1)

.PHONY: tf-backend
tf-backend: check
	@./scripts/create_tf_backend.sh

.PHONY: fmt
fmt:
	terraform fmt -recursive

.PHONY: init
init:
	terraform -chdir=terraform init -backend-config="bucket=${BACKEND_BUCKET}" -backend-config="impersonate_service_account=${SERVICE_ACCOUNT}"

.PHONY: validate
validate:
	terraform -chdir=terraform validate

.PHONY: console
console:
	terraform -chdir=terraform console

.PHONY: plan
plan:
	terraform -chdir=terraform plan -var-file=../variables.tfvars -out=tfplan

.PHONY: apply
apply:
	terraform -chdir=terraform apply -auto-approve tfplan
	rm terraform/tfplan

.PHONY: clean
clean:
	rm *.zip

.PHONY: image
image:
	cd app; docker build -t tts-web-app:latest .

.PHONY: image-no-cache
image-no-cache:
	cd app; docker build --no-cache -t tts-web-app:latest .

.PHONY: local-frontend
local-frontend:
	cd front-end; npm run serve

.PHONY: local-backend
local-backend: image 
	docker run -it -p 8081:8080 --env PORT=8080 --env ENVIRONMENT=dev --env GCS_BUCKET_NAME=tts-utility-354320.appspot.com --env GCLOUD_PROJECT=$(gcloud config get-value project) --mount type=bind,source="${HOME}/.config/gcloud",target="/root/.config/gcloud" tts-web-app:latest

.PHONY: debug-backend
debug-backend: image
	docker run -it -p 8081:8080 --env PORT=8080 --env GCS_BUCKET_NAME=tts-utility-354320.appspot.com --mount type=bind,source="${HOME}/.config/gcloud",target="/root/.config/gcloud" tts-web-app:latest /bin/sh

local:
	make -j 2 local-backend local-frontend
