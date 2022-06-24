all: check init validate plan apply
update: plan apply

.PHONY: check
check:
	@command -v terraform >/dev/null || ( echo "Terraform is not installed!"; exit 1)
	@command -v gcloud >/dev/null || ( echo "gcloud CLI is not installed!"; exit 1)

.PHONY: tf-backend
tf-backend:
	@./scripts/create_tf_backend.sh

.PHONY: fmt
fmt:
	terraform fmt -recursive

.PHONY: init
init:
	terraform -chdir=terraform init

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
local-front-end:
	cd front-end; npm run serve

.PHONY: local-backend
local-backend: image 
	docker run -it -p 8081:8080 --env PORT=8080 --env ENVIRONMENT=dev --mount type=bind,source="${HOME}/.config/gcloud",target="/root/.config/gcloud" tts-web-app:latest

.PHONY: debug-backend
debug-backend: image
	docker run -it -p 8081:8080 --env PORT=8080 --mount type=bind,source="${HOME}/.config/gcloud",target="/root/.config/gcloud" tts-web-app:latest /bin/sh

local:
	make -j 2 local-backend local-frontend
