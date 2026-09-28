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
    # BUG: ROSA module requires terraform-redhat/rhcs provider
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.6.8"
    }
  }
}
