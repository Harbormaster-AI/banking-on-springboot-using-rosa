
# Modules
module "eks" {
  source   = "./eks"
}

module "k8s" {
  source     = "./k8s"
  # Wait for ROSA cluster before creating pods/services
  depends_on = [module.rosa]
}

module "rosa" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.7.4"

  cluster_name      = "bankingOnSpringboot"
  openshift_version = "4.19.0"

  # bug: rosa module expects list(string), not a single subnet id
  aws_subnet_ids = [aws_subnet.default.id, aws_subnet.secondary.id]

  create_account_roles  = true
  create_oidc           = true
  create_operator_roles = true

  create_admin_user = true
}

# bug: was mixing ROSA host/user with EKS CA + `aws eks get-token`.
# Use ROSA admin credentials only (create_admin_user = true).
# Auth for rhcs itself is via RHCS_CLIENT_ID/SECRET (or RHCS_TOKEN) from CI.
provider "kubernetes" {
  host     = module.rosa.cluster_api_url
  username = module.rosa.cluster_admin_username
  password = module.rosa.cluster_admin_password
  insecure = true
}
