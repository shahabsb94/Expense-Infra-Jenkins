resource "aws_instance" "Shabu_Terraform_Instance" {
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
}