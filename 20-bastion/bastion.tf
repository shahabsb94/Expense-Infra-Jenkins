resource "aws_instance" "this" {
  ami                    = "ami-09c813fb71547fc4f" # This is our devops-practice AMI ID
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id   = local.public_subnet_id

  # 20GB is not enough
  root_block_device {
    volume_size = 50  # Set root volume size to 50GB
    volume_type = "gp3"  # Use gp3 for better performance (optional)
  }
  user_data = file("bastion.sh")
  
  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

/* resource "aws_instance" "Shabu_Terraform_Instance" {
  ami                    = var.ami_id
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  instance_type          = var.instance_type
  subnet_id              = local.public_subnet_id

  root_block_device {
    volume_size = 30 # in GB <<----- I increased this!
    volume_type = "gp3"
  }
  user_data = file("bastion.sh")

  tags = merge(
    var.common_tags,
    var.bastion_tags,
    {
      Name = local.resource_name
  })
} */