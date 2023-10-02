module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.9.1" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    vpc-cni = {
      most_recent = true
      #preserve = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller = true
  #enable_cluster_proportional_autoscaler = true
  #enable_karpenter                       = true
  enable_kube_prometheus_stack          = true
  enable_metrics_server                 = true
  enable_external_dns                   = true
  enable_cert_manager                   = true
  cert_manager_route53_hosted_zone_arns = [resource.aws_route53_zone.ingress.arn]
  depends_on                            = [null_resource.update_kubeconfig]

}

data "aws_iam_policy_document" "ebs_csi_controller_sa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(local.oidc_issuer, "https://", "")}"]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_controller_sa" {
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_controller_sa.json
  name               = "${var.prefix}-${var.env}-ebs_csi_controller_sa"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_controller_sa_attach" {
  role       = aws_iam_role.ebs_csi_controller_sa.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "null_resource" "ebs_csi_driver_install" {
  provisioner "local-exec" {
    command = "aws eks create-addon --cluster-name ${module.eks.cluster_name} --addon-name aws-ebs-csi-driver --service-account-role-arn ${aws_iam_role.ebs_csi_controller_sa.arn}"
  }

  depends_on = [module.eks.eks_managed_node_groups, aws_iam_role.ebs_csi_controller_sa]
}

data "aws_iam_policy_document" "eks_cni_driver_addon" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(local.oidc_issuer, "https://", "")}"]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }
  }
}

resource "aws_iam_role" "eks_cni_driver_addon_sa" {
  assume_role_policy = data.aws_iam_policy_document.eks_cni_driver_addon.json
  name               = "${var.prefix}-${var.env}-eks_cni_driver_addon_sa"
}

resource "aws_iam_role_policy_attachment" "eks_cni_driver_addon_sa_attach" {
  role       = aws_iam_role.eks_cni_driver_addon_sa.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "null_resource" "eks_cni_driver_addon" {
  provisioner "local-exec" {
    command = "aws eks create-addon --cluster-name ${module.eks.cluster_name} --addon-name vpc-cni --addon-version v1.15.0-eksbuild.2 --service-account-role-arn ${aws_iam_role.eks_cni_driver_addon_sa.arn}"
  }
  depends_on = [module.eks.eks_managed_node_groups, aws_iam_role.eks_cni_driver_addon_sa]
}

resource "null_resource" "kubecost_addon" {
  provisioner "local-exec" {
    command = "aws eks create-addon --cluster-name ${module.eks.cluster_name} --addon-name kubecost_kubecost --region ${var.aws_region}"
  }
  depends_on = [module.eks.eks_managed_node_groups, aws_iam_role.eks_cni_driver_addon_sa]
}