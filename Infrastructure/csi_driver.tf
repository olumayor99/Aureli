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