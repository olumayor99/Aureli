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