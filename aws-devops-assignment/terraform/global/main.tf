terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = { source = "hashicorp/aws" }
    kubernetes = { source = "hashicorp/kubernetes" }
  }

  backend "s3" {
    bucket = var.tfstate_bucket
    key    = "eks-gitops/terraform.tfstate"
    region = var.region
    encrypt = true
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = merge(var.common_tags, { "managed-by" = "terraform" })
  }
}

# Local to run kubectl/helm via Terraform later if needed
provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
}

# Data lookups used by kubernetes provider (populated after cluster create)
data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
  depends_on = []
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}