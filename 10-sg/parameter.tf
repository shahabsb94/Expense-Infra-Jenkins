
### send the mysql sg_id to ssm parameter ####

resource "aws_ssm_parameter" "mysql_sg_id" {
  name  = "/${var.project_name}/${var.environment}/mysql_sg_id"
  type  = "String"
  value = module.mysql_sg.sg_id
}

### send the bastion sg_id to ssm parameter ####

resource "aws_ssm_parameter" "bastion_sg_id" {
  name  = "/${var.project_name}/${var.environment}/bastion_sg_id"
  type  = "String"
  value = module.bastion_sg.sg_id
}

### send the alb_ingress_sg to ssm parameter ####

resource "aws_ssm_parameter" "alb_ingress_sg" {
  name  = "/${var.project_name}/${var.environment}/alb_ingress_sg"
  type  = "String"
  value = module.alb_ingress_sg.sg_id
}

### send the eks_control_plane_sg to ssm parameter ####

resource "aws_ssm_parameter" "eks_control_plane_sg" {
  name  = "/${var.project_name}/${var.environment}/eks_control_plane_sg"
  type  = "String"
  value = module.eks_control_plane_sg.sg_id
}

### send the eks_node_sg to ssm parameter ####

resource "aws_ssm_parameter" "eks_node_sg" {
  name  = "/${var.project_name}/${var.environment}/eks_node_sg"
  type  = "String"
  value = module.eks_node_sg.sg_id
}

### send the VPN sg_id to ssm parameter ####

# resource "aws_ssm_parameter" "vpn_sg_id" {
#   name  = "/${var.project_name}/${var.environment}/vpn_sg_id"
#   type  = "String"
#   value = module.vpn_sg.sg_id
# }