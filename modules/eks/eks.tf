
provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster_auth" "cluster_auth" {
  # name = module.eks-cluster.eks_cluster.name
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = var.cluster_token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = var.cluster_token

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}



resource "aws_iam_role" "eks_cluster" {
  name = "iam-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "eks_node" {
  name = "iam-eks-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}


locals {
  ami_type            = var.ami_type
  instance_type_nodes = var.instance_type_nodes
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name                   = var.cluster_name
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }


  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]

      desired_size = 3
      max_size     = 6
      min_size     = 1
    }

  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
  ]

  tags = var.tags
}



resource "helm_release" "rabbitmq" {
  name       = var.k8s_name_rabbitmq
  repository = var.helm_repo
  chart      = var.helm_chart_rabbitmq
  version    = var.helm_chart_version_rabbitmq

  depends_on = [module.eks]
}

resource "helm_release" "postgres" {
  name       = var.k8s_name_postgres
  repository = var.helm_repo
  chart      = var.helm_chart_postgres
  version    = var.helm_chart_version_postgres

  depends_on = [module.eks]
}

resource "helm_release" "mongo_payment" {
  name       = var.k8s_name_mongo_payment
  repository = var.helm_repo
  chart      = var.helm_chart_mongo_payment
  version    = var.helm_chart_version_mongo_payment

  depends_on = [module.eks]
}

resource "helm_release" "mongo_production" {
  name       = var.k8s_name_mongo_production
  repository = var.helm_repo
  chart      = var.helm_chart_mongo_production
  version    = var.helm_chart_version_mongo_production

  depends_on = [module.eks]
}

resource "helm_release" "payment_manager" {
  name       = var.k8s_name_payment_manager
  repository = var.helm_repo
  chart      = var.helm_chart_payment_manager
  version    = var.helm_chart_version_payment_manager

  depends_on = [module.eks, helm_release.rabbitmq, helm_release.mongo_payment]
}

resource "helm_release" "production_manager" {
  name       = var.k8s_name_production_manager
  repository = var.helm_repo
  chart      = var.helm_chart_production_manager
  version    = var.helm_chart_version_production_manager

  depends_on = [module.eks, helm_release.rabbitmq, helm_release.mongo_production]
}

resource "helm_release" "order_manager" {
  name       = var.k8s_name_order_manager
  repository = var.helm_repo
  chart      = var.helm_chart_order_manager
  version    = var.helm_chart_version_order_manager

  depends_on = [module.eks, helm_release.rabbitmq, helm_release.postgres]
}
