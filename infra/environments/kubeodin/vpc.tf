module "vpc" {
  source = "../../modules/vpc"

  name = "${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]

  database_subnets = [
    "10.0.21.0/24",
    "10.0.22.0/24",
    "10.0.23.0/24"
  ]

  public_subnet_tags = {
    "Tier" = "Public"
  }

  private_subnet_tags = {
    "Tier" = "Private-App"
  }

  database_subnet_tags = {
    "Tier" = "Private-Data"
  }

  enable_nat_gateway = false
}