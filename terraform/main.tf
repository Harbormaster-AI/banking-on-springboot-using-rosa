
            # -------------------------------------------------------
# Specify the provider and access details
# -------------------------------------------------------
provider "aws" {
  region     = "us-east-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      CreatedBy = "Harbormaster"
      Blueprint = "Spring Boot 3.5"
      DomainModel = "Banking Industry Domain Model"
      CertificationId = "7642e805-e50a-472a-b771-7d08a6986148"
    }
  }
}

# BUG: ROSA needs explicit rhcs provider. Auth via env (do not hardcode):
#   RHCS_CLIENT_ID + RHCS_CLIENT_SECRET  (recommended service account)
#   or RHCS_TOKEN (legacy offline token)
provider "rhcs" {}

# -------------------------------------------------------
# VPC for ROSA HCP
# -------------------------------------------------------
# BUG: ROSA HCP requires ≥1 private subnet per AZ that is used.
# Public-only (or public in AZ-a only) fails with:
#   "1 private subnet is required per zone. Only public subnets were specified"

resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  depends_on    = [aws_internet_gateway.default]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default.id
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# -------------------------------------------------------
# Security groups + RDS (kept; app DB)
# -------------------------------------------------------

resource "aws_security_group" "web" {
  description = "security group for application bankingonspringboot created from terraform"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  description = "security group for bankingonspringboot and mysql created from terraform"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "bankingonspringboot-db-subnet"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_db_instance" "default" {
  depends_on             = [aws_security_group.db]
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.medium"
  db_name                = "bankingonspringboot"
  username               = "no_user_name"
  password               = "no_password"
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  skip_final_snapshot    = true
}

# -------------------------------------------------------
# ELIMINATE FOR ROSA (do not generate these in ROSA blueprint)
# -------------------------------------------------------
# BUG: EKS + EC2 docker path conflict with ROSA, cause cost on every failed
# apply, and leave orphans (no remote TF state). Deploy app via OpenShift/k8s.

# resource "tls_private_key" "generated" {
#   algorithm = "RSA"
# }
#
# resource "local_file" "public_key_openssh" {
#   content  = tls_private_key.generated.public_key_openssh
#   filename = local.public_key_filename
# }
#
# resource "local_file" "private_key_pem" {
#   content  = tls_private_key.generated.private_key_pem
#   filename = local.private_key_filename
# }
#
# resource "aws_key_pair" "generated" {
#   key_name   = "pjsk-sshtest-0.35548590304413574"
#   public_key = tls_private_key.generated.public_key_openssh
#   lifecycle { ignore_changes = [key_name] }
# }
#
# resource "aws_iam_role" "eks" { ... }
# resource "aws_iam_role_policy_attachment" "eks_cluster_policy" { ... }
# resource "aws_eks_cluster" "this" { ... }
#
# resource "aws_instance" "web" {
#   ... docker login with hardcoded password — also a security bug ...
# }
#
# output "ssh_command" { ... }
