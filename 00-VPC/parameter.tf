

### to store the created VPC ID in SSM parameter store in AWS we have to use this ####

resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project_name}/${var.environment}/vpc_id" ## --- /expense/dev/vpc_id --- name should start with /
  type  = "String"
  value = module.main.vpc_id
}

### to store the created public_subnet_ids ID in SSM parameter store in AWS we have to use this ####

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/public_subnet_ids" ## --- /expense/dev/public_subnet_ids --- name should start with /
  type  = "StringList"
  value = join(", ", module.main.public_subnet_ids)
}

### to store the created private_subnet_ids ID in SSM parameter store in AWS we have to use this ####

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/private_subnet_ids" ## --- /expense/dev/private_subnet_ids --- name should start with /
  type  = "StringList"
  value = join(", ", module.main.private_subnet_ids)
}

### to store the created database_subnet_ids ID in SSM parameter store in AWS we have to use this ####

resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/database_subnet_ids" ## --- /expense/dev/database_subnet_ids --- name should start with /
  type  = "StringList"
  value = join(", ", module.main.database_subnet_ids)
}

##### Store created Database subnet group name in SSM parameters #####

resource "aws_ssm_parameter" "database_subnet_group_name" {
  name  = "/${var.project_name}/${var.environment}/database_subnet_group_name" ## --- /expense/dev/database_subnet_group_name --- name should start with /
  type  = "String"
  value = aws_db_subnet_group.expense.name
}