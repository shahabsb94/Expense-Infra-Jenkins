resource "aws_key_pair" "eks" {
  key_name   = "expense-eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1bifWW6P3hUPCKgA7XqLmVPreniLtjNYOU6dBiBmDKt+blTE8CcUWpPaKlHKT+qWRsq8NTp5GmjAeaZvaiZTgO9S08hDsuQA9Ddpl7TfAo6sNpmxyWPwtpE+KNDM5fuwmDjeCp2r9wq66BPakwGj4oAIiYHQKeQQ3Pz84laqX6/0EyRK06+SbuA2BGPnRvx4w9jYEjOIdAivCmfW0S1eq0ilg68SZE8nynIcb9lPkBL2AwAvTZQlsHRcqi/HbQV+aVf2nM68yMmTZJKTZaE3mITW0ot4c3rhexewOwtoI5SB5V1UplDZYfhtWKK12eQNpH54+MgWqfOh6Xl4bRg69/eZJWbAz2NmYJgqQKu5fC5r4HspyfF37tgwV5kCCbdX1aotTEAXSJxXaOZUg7vEztKEVQFwkLMe7LBFiZoFe4vLw+dZv4Boy6GV/MGr8bsV/jggjRA7UYRgCMHpYhTuqAQsYo4JKHsvbUqnRSMKY9WWRU5fZGn0l/TDply1ySL+nffpnhjPJcQ8+nxgURhnY9Pa9UzOLPAY0DIQs8lFND0iwRczYy+mX9YGG2mRoCAH2nKUyc3QO1SqJ/KR+uBvmsOK/EWqv20rpX164HR3he8/MZJcIqp8SVA1JLQ7cj95KJmSGXABJqTDvRD9Nx8OrzL3yUnQpg6RfYtR37oMsvQ== syedayazuddin@SYEDs-MacBook-Air.local"
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