
#####. Mysql Security Group #####

module "mysql_sg" {
  #source = "../Terraform-aws-SecurityGroup-Module"
  source = "git::https://github.com/shahabsb94/Terraform-aws-SecurityGroup-Module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "mysql"
  sg_description = "Created for MySQL instances in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

#####. bastion server Security Group #####

module "bastion_sg" {
  #source = "../Terraform-aws-SecurityGroup-Module"
  source = "git::https://github.com/shahabsb94/Terraform-aws-SecurityGroup-Module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "bastion"
  sg_description = "Created for bastion instances in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

##### VPN Security Group Open ports 22, 443, 1194, 943 #####

module "vpn_sg" {
  #source = "../Terraform-aws-SecurityGroup-Module"
  source = "git::https://github.com/shahabsb94/Terraform-aws-SecurityGroup-Module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "vpn"
  sg_description = "Created for VPN  in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

##### APP ALB  Security Group #####

module "alb_ingress_sg" {
  #source = "../Terraform-aws-SecurityGroup-Module"
  source = "git::https://github.com/shahabsb94/Terraform-aws-SecurityGroup-Module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "app-alb"
  sg_description = "Created for backend ALB in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

module "eks_control_plane_sg" {
  #source = "../Terraform-aws-SecurityGroup-Module"
  source = "git::https://github.com/shahabsb94/Terraform-aws-SecurityGroup-Module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "eks_control_plane"
  sg_description = "Created for backend ALB in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}

module "eks_node_sg" {
  #source = "../Terraform-aws-SecurityGroup-Module"
  source = "git::https://github.com/shahabsb94/Terraform-aws-SecurityGroup-Module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "eks_node"
  sg_description = "Created for backend ALB in expense dev"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
}


################################# aws security group rule #################################

## eks control plane master accepting traffic form node

resource "aws_security_group_rule" "eks_control_plane_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_node_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}

## node accepting traffic from maste control plane

resource "aws_security_group_rule" "eks_node_eks_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_control_plane_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

## Node accepting traffic from alb ingress

# resource "aws_security_group_rule" "node_alb_ingress" {
#   type              = "ingress"
#   from_port         = 30000
#   to_port           = 32767
#   protocol          = "tcp"
#   source_security_group_id = module.alb_ingress_sg.sg_id
#   security_group_id = module.eks_node_sg.sg_id
# }

## Node accepting traffic from vpc 10.0.0.0/16 

resource "aws_security_group_rule" "node_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"] # our private ip add range -->internal traffic
  security_group_id = module.eks_node_sg.sg_id
}

## Node accepting traffic from bastion

resource "aws_security_group_rule" "node_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

#### APP ALB accepting traffic from bastion server irrespective of bastion IP addess #### 

resource "aws_security_group_rule" "alb_ingress_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.alb_ingress_sg.sg_id
}

## alb ingree accepting traffic form bastion https 

resource "aws_security_group_rule" "alb_ingress_bastion_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.alb_ingress_sg.sg_id
}

## alb ingree accepting traffic form http public

resource "aws_security_group_rule" "alb_ingress_public_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = module.alb_ingress_sg.sg_id
}


#### bastion Server SSH rule to login into the server #### 

resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id
}


#### mysql accepting connection from bastion host #### 

resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

#### mysql accepting connection from eks nodes #### 

resource "aws_security_group_rule" "mysql_eks_node" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.eks_node_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

#### ekse control plane accepting traffic form bastion #### 

resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}

resource "aws_security_group_rule" "eks_node_alb_ingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.alb_ingress_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}















