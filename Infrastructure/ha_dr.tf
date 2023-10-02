data "aws_iam_policy_document" "cluster_autoscaler" {
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
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name = "${var.prefix}-cluster-autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "cluster_autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler.json
  name               = "${var.prefix}-cluster-autoscaler"
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  #version          = "9.29.1"
  version = var.cluster_autoscaler_helm_version

  set {
    name  = "awsRegion"
    value = var.aws_region
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
    type  = "string"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "default"
  }

  spec {
    min_replicas                      = 2
    max_replicas                      = 5
    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "frontend"
    }
  }

  depends_on = [null_resource.aureli_deployment]
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "backend" {
  metadata {
    name      = "backend"
    namespace = "default"
  }

  spec {
    min_replicas                      = 2
    max_replicas                      = 5
    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "backend"
    }
  }

  depends_on = [null_resource.aureli_deployment]
}

resource "helm_release" "litmus_chaos" {
  name             = "litmus-chaos"
  namespace        = "litmus"
  repository       = "https://litmuschaos.github.io/litmus-helm/"
  chart            = "litmus"
  version          = "2.15.10"
  create_namespace = true
  depends_on       = [module.eks_blueprints_addons]
}


