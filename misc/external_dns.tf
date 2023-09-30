# ExternalDNS
data "aws_iam_policy_document" "external_dns_sts_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(local.oidc_issuer, "https://", "")}"]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:external-dns"]
    }
  }
}

resource "aws_iam_role" "external_dns" {
  assume_role_policy = data.aws_iam_policy_document.external_dns_sts_policy.json
  name               = "${var.prefix}-${var.env}-external-dns"
}

resource "aws_iam_policy" "external_dns" {
  name = "${var.prefix}-${var.env}-external-dns"
  policy = jsonencode({
    Statement = [{
      Action = [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "external_dns_policy_attach" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name = "external-dns"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
    }
  }
  automount_service_account_token = true
}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "oci://registry-1.docker.io/bitnamicharts/"
  chart            = "external-dns"
  version          = "6.26.1"

  set {
    name  = "txtOwnerId"
    value = aws_route53_zone.ingress.zone_id
  }
  set {
    name  = "domainFilters[0]"
    value = aws_route53_zone.ingress.name
  }
  set {
    name  = "serviceAccount.labels[0]"
    value = "app.kubernetes.io/managed-by=Helm"
  }
  set {
    name  = "serviceAccount.annotations[0]"
    value = "meta.helm.sh/release-name=external-dns"
  }
  set {
    name  = "serviceAccount.annotations[1]"
    value = "meta.helm.sh/release-namespace=default"
  }
}