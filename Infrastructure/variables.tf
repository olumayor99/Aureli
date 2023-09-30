variable "prefix" {
  type= string
  default     = "Aureliii"
  description = "Prefix resource names"
}
variable "aws_region" {
  type= string
  default     = "us-east-1"
  description = "VPC region"
}

variable "env" {
  type= string
  default     = "Dev"
  description = "Environment"
}

variable "vpc_cidr" {
  type= string
  default     = "10.50.0.0/16"
  description = "VPC CIDR range"
}
variable "domain_name" {
   type= string
   default= "drayco.com" # Replace with your own domain name
   description= "domain name"

}

variable "istio_chart_url" {
   type= string
   default= "https://istio-release.storage.googleapis.com/charts"
   description= "Istio Chart URL"
}

variable "istio_chart_version" {
   type= string
   default= "1.18.1"
   description= "Istio Chart Version"
}

variable "cluster_autoscaler_helm_version" {
   type= string
   default= "9.29.3"
   description= "Cluster Autoscaler Chart Version"
}
