# ============================================================
# GitHub Actions OIDC Provider
# ============================================================
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  
  # Both official GitHub SSL Thumbprints (fixes: "token could not be validated")
  thumbprint_list = [
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name      = "github-actions-oidc"
    ManagedBy = "Terraform"
  }
}

# ============================================================
# IAM Role for GitHub Actions
# ============================================================
resource "aws_iam_role" "github_actions" {
  name = "devsecops-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Matches BOTH GitHub formats (with and without numeric ID)
            "token.actions.githubusercontent.com:sub" = [
              "repo:himanshu2oo4@86143385/Zero-Trust-Software-Supply-Chain-Pipeline-SLSA-Compliant@1436026323:*",
              "repo:himanshu2oo4/Zero-Trust-Software-Supply-Chain-Pipeline-SLSA-Compliant:*"
            ]
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
# Policy Attachments
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

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# CloudWatch Logs (fixes: "DescribeLogGroups not authorized")
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name = "cloudwatch-logs-access"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:*"]
        Resource = "*"
      }
    ]
  })
}

# EKS and supporting services
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
# Output
# ============================================================
output "github_actions_role_arn" {
  description = "Role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}