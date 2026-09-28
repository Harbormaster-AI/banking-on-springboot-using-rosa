# BUGS — ROSA terraform / blueprint (`banking-on-springboot-using-rosa`)

**Source repo:** Harbormaster-AI/banking-on-springboot-using-rosa  
**Docker image (unchanged):** `theharbormaster/banking-on-springboot:latest`  
**Verification:** HarborMaster system-verification **Cloud Only** workflow against this app’s `terraform/`

---

## Eliminate when generating a ROSA blueprint

Do **not** emit these for a ROSA target (they conflict with ROSA, add cost, and leave orphans when CI has no remote Terraform state):

1. **EKS path** — `aws_eks_cluster`, EKS IAM roles/policies, `module.eks`
2. **EC2 application path** — `aws_instance` + docker `remote-exec` (and SSH key material used only for that)
3. **Kubernetes provider wired to EKS** — EKS certificate authority + `aws eks get-token`
4. **Hardcoded container-registry credentials** in terraform provisioners

Application deploy for ROSA should be via **OpenShift / Kubernetes on the ROSA cluster** only (after the cluster API is available).

---

## Required generator / terraform fixes

| # | Problem | Where | Required behavior |
|---|---------|--------|-------------------|
| 1 | `aws_subnet_ids` passed as a **string** | `terraform/k8.aws.main.tf` | Pass `list(string)` |
| 2 | Missing `provider "rhcs"` / `rhcs` in required_providers | `terraform/main.tf`, `versions.tf` | Declare provider; auth via env `RHCS_CLIENT_ID` + `RHCS_CLIENT_SECRET` (or `RHCS_TOKEN`) — never hardcode |
| 3 | Kubernetes provider mixes ROSA host/user with EKS CA/exec | `terraform/k8.aws.main.tf` | Use ROSA admin credentials only |
| 4 | `terraform.sh` plan line-continuation broken; invalid `-var aws-access-key=empty` | `terraform/terraform.sh` | Continuous `plan -out=terraform.plan`; do not override CI `TF_VAR_aws_*` with empty dummy vars (names must use underscores) |
| 5 | `openshift_version = "4.19.0"` rejected by OCM | `terraform/k8.aws.main.tf` | Use a **supported** patch version from OCM (e.g. `4.19.47`), not bare `x.y.0` if unsupported |
| 6 | `cluster_name` camelCase rejected | `terraform/k8.aws.main.tf` | Lowercase alphanumeric + hyphens only (e.g. `banking-on-springboot`) |
| 7 | Subnets insufficient for ROSA HCP | `terraform/main.tf` | Public + **private** subnets in ≥2 AZs, NAT for privates; pass public+private IDs to the ROSA module |
| 8 | Kubernetes provider fails plan when cluster API URL is unknown | `terraform/k8.aws.main.tf` | **Two-phase** apply: create ROSA cluster first, then apply workloads (or equivalent split roots / targeting) |

---

## Account / environment prerequisites (ops)

Not blueprint code, but required before Cloud Only can finish ROSA create:

1. **AWS account enabled for ROSA** and **linked** to the Red Hat organization (AWS Marketplace).  
   Failure seen: `billing account … not linked to organization … at the aws marketplace`  
   Enabling the Marketplace offer itself is **$0**; creating a cluster incurs AWS/ROSA usage charges.

2. **Service quotas** in the target region must meet ROSA minimums (e.g. EC2 On-Demand Standard instances often need **100**; lower values block prerequisites). Quota **requests** are not a purchase; approval may lag while the console still shows “Increase service quotas”.

3. **Remote Terraform state** is recommended. Without it, failed CI applies leave orphan EC2/EKS/VPC/IAM resources that must be deleted manually.

---

## Suggested ROSA blueprint output

1. ROSA HCP module + `rhcs` provider + CI env wiring for Red Hat auth  
2. VPC: 2 public + 2 private subnets + NAT  
3. Lowercase `cluster_name`; OCM-supported `openshift_version`  
4. No EKS and no EC2 docker deploy path  
5. App manifests / kubernetes resources in a **second** stage after cluster API exists  
6. `terraform.sh` that correctly writes and applies a saved plan without overriding secrets  

---

## Local patch set (this working copy)

Minimal terraform-only adjustments matching the table above (EKS/EC2 paths commented with notes; app application sources unchanged):

- `terraform/versions.tf`
- `terraform/main.tf`
- `terraform/k8.aws.main.tf`
- `terraform/terraform.sh`
