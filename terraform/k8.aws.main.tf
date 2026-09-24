
# Modules
module "eks" {
  source   = "./eks"
}

# ---------------------------------------------------------------------------
# bug: kubernetes provider cannot plan when ROSA API URL is not known yet.
# Error: "cannot load Kubernetes client config" /
#        "default cluster has no server defined"
#
# Host/username/password all come from module.rosa (known after apply).
# hashicorp/kubernetes then falls back to empty kubeconfig and fails plan.
#
# Temporary: skip k8s app deploy until ROSA cluster exists (two-phase apply
# or generator fix). Re-enable module.k8s + provider after cluster_api_url
# is available, or split terraform into cluster-then-workloads stages.
# ---------------------------------------------------------------------------
# module "k8s" {
#   source     = "./k8s"
#   depends_on = [module.rosa]
# }

module "rosa" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.7.4"

  cluster_name = "bankingOnSpringboot"
  # bug: exact 4.19.0 is not in OCM supported list; use a supported patch (e.g. 4.19.47)
  openshift_version = "4.19.47"

  # bug: rosa module expects list(string), not a single subnet id
  aws_subnet_ids = [aws_subnet.default.id, aws_subnet.secondary.id]

  create_account_roles  = true
  create_oidc           = true
  create_operator_roles = true

  create_admin_user = true
}

# provider "kubernetes" {
#   host     = module.rosa.cluster_api_url
#   username = module.rosa.cluster_admin_username
#   password = module.rosa.cluster_admin_password
#   insecure = true
# }
