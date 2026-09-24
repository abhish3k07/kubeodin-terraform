variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
}

variable "cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones names or IDs in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "A list of database subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags for the database subnets"
  type        = map(string)
  default     = {}
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for your Private Subnets"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all private subnets"
  type        = bool
  default     = true
}

variable "create_igw_route_for_private" {
  description = "Connect Internet Gateway route (0.0.0.0/0) to private subnets when NAT Gateway is disabled"
  type        = bool
  default     = true
}

variable "create_igw_route_for_database" {
  description = "Connect Internet Gateway route (0.0.0.0/0) to database subnets"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch_private" {
  description = "Should be true to auto-assign public IP on launch for private subnets"
  type        = bool
  default     = false
}

variable "map_public_ip_on_launch_database" {
  description = "Should be true to auto-assign public IP on launch for database subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
