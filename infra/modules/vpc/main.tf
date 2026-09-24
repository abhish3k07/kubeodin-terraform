# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = (length(var.public_subnets) > 0 || var.create_igw_route_for_private || var.create_igw_route_for_database) ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-igw"
    },
    var.tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = length(var.azs) > 0 ? var.azs[count.index % length(var.azs)] : null
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.name}-public-${length(var.azs) > 0 ? var.azs[count.index % length(var.azs)] : tostring(count.index + 1)}"
    },
    var.tags,
    var.public_subnet_tags
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = length(var.azs) > 0 ? var.azs[count.index % length(var.azs)] : null
  map_public_ip_on_launch = var.map_public_ip_on_launch_private

  tags = merge(
    {
      Name = "${var.name}-private-${length(var.azs) > 0 ? var.azs[count.index % length(var.azs)] : tostring(count.index + 1)}"
    },
    var.tags,
    var.private_subnet_tags
  )
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.database_subnets[count.index]
  availability_zone       = length(var.azs) > 0 ? var.azs[count.index % length(var.azs)] : null
  map_public_ip_on_launch = var.map_public_ip_on_launch_database

  tags = merge(
    {
      Name = "${var.name}-database-${length(var.azs) > 0 ? var.azs[count.index % length(var.azs)] : tostring(count.index + 1)}"
    },
    var.tags,
    var.database_subnet_tags
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnets)) : 0

  domain = "vpc"

  tags = merge(
    {
      Name = "${var.name}-nat-eip-${count.index + 1}"
    },
    var.tags
  )
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnets)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.name}-nat-${count.index + 1}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

# Route Table - Public
resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-public-rt"
    },
    var.tags
  )
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Route Table - Private
resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 ? (var.single_nat_gateway ? 1 : length(var.private_subnets)) : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = var.single_nat_gateway ? "${var.name}-private-rt" : "${var.name}-private-rt-${count.index + 1}"
    },
    var.tags
  )
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway && length(var.private_subnets) > 0 ? (var.single_nat_gateway ? 1 : length(var.private_subnets)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route" "private_internet_gateway" {
  count = var.create_igw_route_for_private && !var.enable_nat_gateway && length(var.private_subnets) > 0 ? (var.single_nat_gateway ? 1 : length(var.private_subnets)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

# Route Table - Database
resource "aws_route_table" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-database-rt"
    },
    var.tags
  )
}

resource "aws_route" "database_internet_gateway" {
  count = var.create_igw_route_for_database && length(var.database_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.database[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}
