module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name = "${var.prefix}-EKS"
  cluster_version = "1.28"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_enabled_log_types       = ["api", "controllerManager", "scheduler"]


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  enable_irsa = true  # Automatically provisions an OIDC provider. This is preferred to provisioning it separately.

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"  # Should change this to a custom AMI via Packer if OS baking is required.
    disk_size = 50
  }

  eks_managed_node_groups = {
    general = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        Environment = "dev"
        Project = "aureli"
        Type = "on-demand"
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                  = "true"
        "k8s.io/cluster-autoscaler/${var.prefix}-EKS"        = "owned"
      }
    }

    spot = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      labels = {
        Environment = "dev"
        Project = "aureli"
        Type = "spot"
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                       = "true"
        "k8s.io/cluster-autoscaler/${var.prefix}-EKS"        = "owned"
      }
    }
  }

  #  EKS K8s API cluster needs to be able to talk with the EKS worker nodes with port 15017/TCP and 15012/TCP which is used by Istio
  #  Istio in order to create sidecar needs to be able to communicate with webhook and for that network passage to EKS is needed.
  node_security_group_additional_rules = {
    ingress_15017 = {
      description                   = "Cluster API - Istio Webhook namespace.sidecar-injector.istio.io"
      protocol                      = "TCP"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_15012 = {
      description                   = "Cluster API to nodes ports/protocols"
      protocol                      = "TCP"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
}

locals {
  eks_asg_tags = {
    "k8s.io/cluster-autoscaler/enabled" : true
    "k8s.io/cluster-autoscaler/${var.prefix}-EKS" : "owned"
  }
}

resource "aws_autoscaling_group_tag" "nodegroup1" {
  for_each               = local.eks_asg_tags
  autoscaling_group_name = element(module.eks.eks_managed_node_groups_autoscaling_group_names, 0)

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "nodegroup2" {
  for_each               = local.eks_asg_tags
  autoscaling_group_name = element(module.eks.eks_managed_node_groups_autoscaling_group_names, 1)

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
  }
  depends_on = [module.eks.eks_managed_node_groups]
}
