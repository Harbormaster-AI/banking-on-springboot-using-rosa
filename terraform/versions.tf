terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # Required for module.rosa (terraform-redhat/rosa-hcp/rhcs)
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.6.8"
    }
  }
}

