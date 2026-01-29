### we took vpc id from ssm parameters dynamically ###

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id" 
}