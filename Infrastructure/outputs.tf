output "prefix" {
  value       = var.prefix
  description = "Exported common resources prefix"
}
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}
output "vpc_name" {
  value       = module.vpc.name
  description = "VPC Name"
}
output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "VPC public subnets' IDs list"
}
output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "VPC private subnets' IDs list"
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_region" {
  description = "Kubernetes Cluster Region"
  value       = var.aws_region
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "oidc_issuer" {
  value       = module.eks.oidc_provider
  description = "AWS IAM role ARN for EKS Cluster Autoscaler"
}

output "domain_name" {
  value       = var.domain_name
  description = "Hosted Zone name"
}

output "hosted_zone_id" {
  value       = aws_route53_zone.ingress.zone_id
  description = "Hosted Zone ID"
}
output "nameservers" {
  value       = aws_route53_zone.ingress.name_servers
  description = "Hosted Zone ID"
}