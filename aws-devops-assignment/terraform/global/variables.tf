variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tfstate_bucket" {
  type = string
  description = "S3 bucket name for Terraform state backend"
}

variable "eks_cluster_name" {
  type    = string
  default = "eks-gitops"
}

variable "common_tags" {
  type = map(string)
  default = { Project = "eks-gitops" }
}