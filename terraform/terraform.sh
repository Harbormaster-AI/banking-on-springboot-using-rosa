#!/usr/bin/env bash

set -euo pipefail

TERRAFORM_VERSION="${TERRAFORM_VERSION:-1.15.8}"
TERRAFORM_ZIP="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}"

# ============================================================
# Install Terraform
# Usage:
#   ./terraform.sh install
#
# Skip installation:
#   ./terraform.sh
# ============================================================

if [[ "${1:-}" == "install" ]]; then

    echo "Updating apt package index..."
    sudo apt-get update

    echo "Installing required packages..."
    sudo apt-get install -y curl unzip

    echo "Downloading Terraform ${TERRAFORM_VERSION}..."
    curl -fsSLO "${TERRAFORM_URL}"

    echo "Installing Terraform ${TERRAFORM_VERSION}..."
    unzip -o "${TERRAFORM_ZIP}" -d /usr/local/bin/

    echo "Cleaning up..."
    rm -f "${TERRAFORM_ZIP}"

fi


# ============================================================
# Verify Terraform
# ============================================================

echo "Terraform version:"
terraform version

# ============================================================
# Initialize Terraform
# ============================================================

echo "Initializing Terraform..."
terraform init \
    -input=false


# ============================================================
# Validate Terraform configuration
# ============================================================

echo "Validating Terraform configuration..."
terraform validate


# ============================================================
# Create Terraform plan
# ============================================================
# bug: previous script had a blank line after `\` so `-var ...` ran as its
# own command (exit 127: command not found) and plan never used -out.
# Also used invalid names aws-access-key (must be aws_access_key) and
# hardcoded empty which overrode Cloud Only TF_VAR_* secrets.
# AWS keys come from TF_VAR_aws_access_key / TF_VAR_aws_secret_key (Actions).

echo "Creating Terraform plan..."
terraform plan \
    -input=false \
    -out=terraform.plan


# ============================================================
# Apply Terraform plan
# ============================================================

echo "Applying Terraform plan..."
terraform apply \
    -input=false \
    -auto-approve \
    terraform.plan


echo "Terraform provisioning completed successfully."