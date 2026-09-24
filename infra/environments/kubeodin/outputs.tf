output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private app subnets"
  value       = module.vpc.private_subnets
}

output "database_subnets" {
  description = "List of IDs of private data subnets"
  value       = module.vpc.database_subnets
}
