resource "aws_route53_zone" "ingress" {
  name = var.domain_name
}