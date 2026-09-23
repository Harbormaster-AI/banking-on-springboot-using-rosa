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

echo "Creating Terraform plan..."
terraform plan \
    -input=false \
    
-var aws-access-key=empty -var aws-secret-key=empty -var region=us-east-2 \
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