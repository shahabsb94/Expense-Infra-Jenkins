resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoSfN8JoLhVYYR/kKbpzufjBYpr0K3AWtuMTgntlQfGTlAgoB8+Ykr6w7m27HcKcBq9HtMPae2eckHe4niyEpcFw4K8dkHycar5fjGMpsL9UYZKtqLAhrfqU+C9uf/HZe5FrM8oM7hSsxWY16liXsl+b4eifp7V66D6/H7XX5yKp4yfMuaV/ay6jn7n+TdsWhjiYpGTJmx0cmqZ3vTjL7lfYm0Fnn/EZuI7ZKiYzPasrR0JBM+wZf2WYFXJW/5ChXbVHDVRzknVmqERojOhLdV7d8rvlE1Wt6Z96t8o+DWK+MGoO5xvtWHntTM6oGICrWiSuN3z28Qfp22C6jVXVaCNwEAO1PTbW43MFDVjkCrYbeFnRY96dCEeyCZCHglcVJiRrgX8qItTe42aLJ6MkHVG3CDB/7R5JzEcLb03sCiLdVtVmlN7Qw/CpdxgWLpTvJo1sfU0gO8p+I7W81yNB5KL3RYguaG8Jx5X/XIfMJatMU57p4DKXFQU0/AzXvoV6nZU5A3z92fH8ISsl0Z98/U3zDxdPJXbY7U/xr3bUMWnq+E2cVhke5EBDBOpmxkf7CUCYUwcxKpzbS6jBPtTuc1QDTnYic83rX1CzYI+gw4Eq2yL4V026P/U/GvaAKKzx9oVP4V3Ubm/QieICLe0WVptEYPbaJyVp/Ej9o3hiajAw== ec2-user@ip-172-31-6-123.ec2.internal"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.32" # later we upgrade 1.32
  create_node_security_group = false
  create_cluster_security_group = false
  cluster_security_group_id = local.eks_control_plane_sg_id
  node_security_group_id = local.eks_node_sg_id

  #bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server = {}
  }

  # Optional
  cluster_endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    /* blue = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["m5.xlarge"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 2
      max_size     = 10
      desired_size = 2
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    } */

    green = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = ["t3.small"]
      key_name = aws_key_pair.eks.key_name

      min_size     = 1
      max_size     = 1
      desired_size = 1
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
        Name = local.name
    }
  )
}