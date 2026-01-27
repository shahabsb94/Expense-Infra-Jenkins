/* output "azs_info" {
    value = module.vpc.azs_info
} */

# output "subnets_info" {
#     value = module.vpc.subnets_info
# }

output "public_subnet_ids" {
  value = module.main.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.main.public_subnet_ids
}

output "database_subnet_ids" {
  value = module.main.database_subnet_ids
}