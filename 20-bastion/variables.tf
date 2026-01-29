variable "ami_id" {
  type        = string
  default     = "ami-09c813fb71547fc4f"
  description = "This is an RHEL9 AMI"
}

variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "common_tags" {
  type = map(any)
  default = {
    project    = "expense"
    Enviroment = "dev"
    Name       = "bastion-server"
  }
}

variable "bastion_tags" {
  default = {}
}


# 1. command line variables are high priority variables ------> -var "var_name"="var-value"
# 2. terraform.tfvars are 2nd high priority and terraform variables 
# 3. Enviromental variable takes 3rd priority
# 4. default values present in variable.tf 
# 5. if default values and no other variableare defined then terraform ask in the user prompt
