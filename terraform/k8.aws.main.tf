
# Modules
module "eks" {
  source   = "./eks"
}

module "k8s" {
  source   = "./k8s"
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

provider "kubernetes" {
    host     = module.rosa.cluster_api_url
    username = module.rosa.cluster_admin_username
    password = module.rosa.cluster_admin_password
    insecure = true
    cluster_ca_certificate = base64decode(
     aws_eks_cluster.this.certificate_authority[0].data
    )

    exec {
      api_version = "client.authentication.k8s.io/v1"

      command = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        aws_eks_cluster.this.name
      ]
    }
}