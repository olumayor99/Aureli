data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  oidc_issuer = module.eks.oidc_provider
}