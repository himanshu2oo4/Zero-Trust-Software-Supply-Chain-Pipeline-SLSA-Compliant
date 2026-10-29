variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1" # Change if you prefer another region like ap-south-1
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "devsecops-eks-cluster"
}

variable "instance_types" {
  description = "EC2 instance types for the EKS managed node group"
  type        = string
  default     = "c7i-flex.large" # Change if you prefer other instance types
}