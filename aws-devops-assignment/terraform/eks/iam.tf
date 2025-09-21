# Minimal IAM role for EKS cluster (eks module will create more)
resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_cert.sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url
}

# Example: Role for service accounts (IRSA) can be created per-need in other modules
#Note: The terraform-aws-modules/eks module provisions a lot of IAM resources internally. For fine-grained IRSA roles you'll create separate aws_iam_role resources and associate them to service accounts using the module's iam_role_for_service_accounts map or create aws_iam_role + aws_iam_role_policy and annotate service accounts.