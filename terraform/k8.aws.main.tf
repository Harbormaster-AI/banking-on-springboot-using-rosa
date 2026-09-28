
# Modules
# BUG (eliminate for ROSA): EKS path conflicts with ROSA and adds cost.
# module "eks" {
#   source = "./eks"
# }

# BUG: kubernetes provider cannot plan when ROSA API URL is unknown (same apply).
# Use two-phase apply (cluster first, then workloads) in the blueprint.
# module "k8s" {
#   source     = "./k8s"
#   depends_on = [module.rosa]
# }

module "rosa" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.7.4"

  # BUG: name must be lowercase letters/hyphens (not camelCase)
  cluster_name = "banking-on-springboot"
  # BUG: exact 4.19.0 not in OCM supported list — use a supported patch
  openshift_version = "4.19.47"

  # BUG: must be list(string); ROSA HCP needs private subnet per AZ used
  aws_subnet_ids = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]

  create_account_roles  = true
  create_oidc           = true
  create_operator_roles = true

  create_admin_user = true
}

# BUG: do not mix ROSA host/user with EKS CA + `aws eks get-token`.
# When re-enabling k8s workloads (phase 2), use ROSA admin only:
# provider "kubernetes" {
#   host     = module.rosa.cluster_api_url
#   username = module.rosa.cluster_admin_username
#   password = module.rosa.cluster_admin_password
#   insecure = true
# }
