# ============================================================
# CREATE GitHub OIDC Provider fresh (deleted from AWS)
# ============================================================
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1" , "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]

  

  tags = {
    Name      = "github-actions-oidc"
    ManagedBy = "Terraform"
  }
}

# Get current AWS account details dynamically
data "aws_caller_identity" "current" {}

# ============================================================
# IAM Role that GitHub Actions will assume via OIDC
# ============================================================
resource "aws_iam_role" "github_actions" {
  name = "devsecops-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # Now references the resource we CREATE above
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # GitHub new format includes numeric User ID and Repo ID in sub
            "token.actions.githubusercontent.com:sub" = "repo:himanshu2oo4@86143385/Zero-Trust-Software-Supply-Chain-Pipeline-SLSA-Compliant@1436026323:*"
          }
        }
      }
    ]
  })

  tags = {
    Name      = "github-actions-role"
    ManagedBy = "Terraform"
  }
}

# ============================================================
# Attach Permissions to the Role
# ============================================================
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_full_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "vpc_full_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}



resource "aws_iam_role_policy" "eks_additional" {
  name = "eks-additional-permissions"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ecr:*",
          "autoscaling:*",
          "elasticloadbalancing:*",
          "cloudformation:*",
          "kms:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================================
# Outputs
# ============================================================
output "github_actions_role_arn" {
  description = "Add this to GitHub Secrets as AWS_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}

output "aws_account_id" {
  description = "Current AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}




