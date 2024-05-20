
variable "intra_subnets" {
}

variable "private_subnets" {
}

variable "vpc_id" {
}


variable "cluster_name" {
}


variable "cluster_token" {
}

variable "node_group_name" {
}

variable "instance_type_nodes" {
}

variable "ami_type" {
}

variable "tags" {
}



variable "aws_region" {

}

# K8S


variable "k8s_name_mongo_payment" {}
variable "k8s_name_mongo_production" {}
variable "k8s_name_postgres" {}
variable "k8s_name_rabbitmq" {}
variable "k8s_name_payment_manager" {}
variable "k8s_name_production_manager" {}
variable "k8s_name_order_manager" {}


variable "helm_repo" {
}

// RABBITMQ
variable "helm_chart_rabbitmq" {
}

variable "helm_chart_version_rabbitmq" {
}

// POSTGRES
variable "helm_chart_postgres" {
}

variable "helm_chart_version_postgres" {
}

// MONGO
variable "helm_chart_mongo_payment" {
}

variable "helm_chart_version_mongo_payment" {
}

variable "helm_chart_mongo_production" {
}

variable "helm_chart_version_mongo_production" {
}

// Payment Manager
variable "helm_chart_payment_manager" {
}

variable "helm_chart_version_payment_manager" {
}

// Production Manager
variable "helm_chart_production_manager" {
}

variable "helm_chart_version_production_manager" {
}

// Order Manager
variable "helm_chart_order_manager" {
}

variable "helm_chart_version_order_manager" {
}

