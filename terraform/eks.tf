module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  # Allows you to connect to the cluster from your laptop's public internet IP
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # hosting the cluster in private subnet 

  # Authentication: Grants the creator of the cluster full admin rights
  enable_cluster_creator_admin_permissions = true

  # EKS Managed Node Group (The EC2 worker machines)
  eks_managed_node_groups = {
    main = {
      name           = "devsecops-node-group"
      instance_types = [var.instance_types]
      ami_type = "AL2023_x86_64_STANDARD"
      min_size     = 1
      max_size     = 2
      desired_size = 1

      capacity_type = "ON_DEMAND"

      tags = {
        Environment = "production"
        ManagedBy   = "Terraform"
      }
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}