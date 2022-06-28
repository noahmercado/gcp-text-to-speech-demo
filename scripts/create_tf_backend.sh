#!/usr/bin/env bash

ROOT_DIR="$( cd -- "$(dirname "$(dirname -- "${BASH_SOURCE[0]}" )")" &> /dev/null && pwd )"
BACKEND_CONFIG_FILE="${ROOT_DIR}/config/.backend.lock.yml"
PROJECT_ID=$(gcloud config get-value project)
CURRENT_USER=$(gcloud config get-value account)
CWD=$(pwd)
BILLING_ACCOUNT_ID=$(gcloud alpha billing accounts list --format="value(ACCOUNT_ID)")
ORGANIZATION_ID=$(gcloud organizations list --format="value(ID)")

RANDOM_INT=$((1000 + $RANDOM % 100000))
BUCKET_NAME="${PROJECT_ID}-tf-backend-${RANDOM_INT}"
BUCKET_NAME_WITH_PROTO="gs://${BUCKET_NAME}"

function validate_backend_exists() {
    if [[ -f ${BACKEND_CONFIG_FILE} ]]
    then
        echo "The backend has already been configured.."
        echo ""
        echo "$(cat $BACKEND_CONFIG_FILE)"
        echo ""
        echo "Exiting..."
        exit 0
    fi
}

function enable_apis() {
    while IFS= read -r API; do
        echo "Enabling $API..."
        gcloud services enable $API
    done <"$ROOT_DIR/config/apis.txt"

    echo "Allowing time to propagate..."
    sleep 30
}

function disable_policies() {
    while IFS= read -r POLICY; do
        echo "Disabling $POLICY in ${PROJECT_ID}..."
        gcloud alpha --quiet resource-manager org-policies disable-enforce ${POLICY} --project=${PROJECT_ID} > /dev/null 2>&1
    done <"$ROOT_DIR/config/disable_boolean_constraint_policies.txt"

    while IFS= read -r POLICY; do
        echo "Disabling $POLICY in ${PROJECT_ID}..."
        gcloud --quiet org-policies reset ${POLICY} --project=${PROJECT_ID} > /dev/null 2>&1
    done <"$ROOT_DIR/config/disable_list_constraint_policies.txt"

    echo "Allowing time to propagate..."
    sleep 180
}

function create_bucket() {
    echo "Creating bucket ${BUCKET_NAME_WITH_PROTO} in ${PROJECT_ID} within us-central1 ..."
    gsutil mb -c standard -b on -l us-central1 $BUCKET_NAME_WITH_PROTO  > /dev/null 2>&1 && \
        gsutil versioning set on $BUCKET_NAME_WITH_PROTO
    sed -i '' "s/TERRAFORM_BACKEND_BUCKET_NAME/${BUCKET_NAME}/g" "${ROOT_DIR}/terraform/main.tf"
}

function create_service_account() {
    echo "Creating Terraform service account in ${PROJECT_ID} ..."
    gcloud iam service-accounts create terraform --display-name="Terraform Service Account"
    SERVICE_ACCOUNT="terraform@${PROJECT_ID}.iam.gserviceaccount.com"

    gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT} \
        --member="user:${CURRENT_USER}" \
        --role='roles/iam.serviceAccountTokenCreator'

    while IFS= read -r ROLE; do
        echo "Assigning ${ROLE} to ${SERVICE_ACCOUNT}..."
        gcloud projects add-iam-policy-binding ${PROJECT_ID} \
            --member="serviceAccount:${SERVICE_ACCOUNT}" \
            --role=${ROLE}
    done <"$ROOT_DIR/config/roles.txt"

    echo "Allowing time to propagate..."
    sleep 30
}

function generate_config_file() {
    echo "Generating backend config file ..."
    touch "${BACKEND_CONFIG_FILE}"
    echo "project: \"${PROJECT_ID}\"" >> "${BACKEND_CONFIG_FILE}"
    echo "bucket: \"${BUCKET_NAME}\"" >> "${BACKEND_CONFIG_FILE}"
    echo "serviceAccount: \"${SERVICE_ACCOUNT}\"" >> "${BACKEND_CONFIG_FILE}"
    echo "billingAccount: \"${BILLING_ACCOUNT_ID}\"" >> "${BACKEND_CONFIG_FILE}"
}

function end() {
    echo "Done!"
}

set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command exited with exit code $?."' EXIT

validate_backend_exists
enable_apis
# disable_policies
create_bucket
create_service_account
generate_config_file
end