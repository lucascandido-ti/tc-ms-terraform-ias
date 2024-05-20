module "vpc" {
  source       = "./modules/vpc"
  vpc_name     = local.vpc_name
  azs          = data.aws_availability_zones.available.names
  cluster_name = local.cluster_name
}

module "cluster_eks_k8s" {
  source     = "./modules/eks"
  aws_region = var.aws_region

  cluster_name        = local.cluster_name
  node_group_name     = local.node_group_name
  private_subnets     = module.vpc.private_subnets
  instance_type_nodes = var.instance_type_nodes
  intra_subnets       = module.vpc.intra_subnets
  vpc_id              = module.vpc.vpc_id
  ami_type            = var.ami_type
  tags                = local.common_tags

  cluster_token = data.aws_eks_cluster_auth.cluster.token

  k8s_name_mongo_payment = local.k8s_name_mongo_payment
  k8s_name_mongo_production = local.k8s_name_mongo_production
  k8s_name_postgres = local.k8s_name_postgres
  k8s_name_rabbitmq = local.k8s_name_rabbitmq
  k8s_name_payment_manager = local.k8s_name_payment_manager
  k8s_name_production_manager = local.k8s_name_production_manager
  k8s_name_order_manager = local.k8s_name_order_manager

  helm_repo             = local.helm_repository
  
  helm_chart_rabbitmq         = local.helm_queue.name
  helm_chart_version_rabbitmq = local.helm_queue.version
  
  helm_chart_postgres         = local.helm_postgres.name
  helm_chart_version_postgres = local.helm_postgres.version
  
  helm_chart_mongo_payment         = local.helm_mongo_payment.name
  helm_chart_version_mongo_payment = local.helm_mongo_payment.version
  
  helm_chart_mongo_production         = local.helm_mongo_production.name
  helm_chart_version_mongo_production = local.helm_mongo_production.version

  helm_chart_payment_manager         = local.helm_payment_manager.name
  helm_chart_version_payment_manager = local.helm_payment_manager.version

  helm_chart_production_manager         = local.helm_production_manager.name
  helm_chart_version_production_manager = local.helm_production_manager.version

  helm_chart_order_manager         = local.helm_order_manager.name
  helm_chart_version_order_manager = local.helm_order_manager.version

}
