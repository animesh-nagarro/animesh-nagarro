module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  subnets = var.private_subnets
  vpc_id  = var.vpc_id

  manage_aws_auth = true

  node_groups = {
    system = {
      desired_capacity = 1
      min_capacity     = 1
      max_capacity     = 2
      instance_type    = var.system_instance_type
      tags             = merge(var.common_tags, { "role" = "system" })
    }
    app = {
      desired_capacity = var.app_node_count
      min_capacity     = 1
      max_capacity     = 3
      instance_type    = var.app_instance_type
      tags             = merge(var.common_tags, { "role" = "app" })
    }
  }

  # enable IRSA (OIDC provider) to allow IAM for service accounts
  enable_irsa = true

  tags = merge(var.common_tags, { "Name" = var.cluster_name })
}

# Data sources for kubeconfig/provider usage elsewhere
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}