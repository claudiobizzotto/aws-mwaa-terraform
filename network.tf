# MWAA network

data "aws_availability_zones" "availability_zones" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "${var.prefix}-vpc"
  })
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.availability_zones.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = format("${var.prefix}-public%02d", count.index + 1)
  })
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.availability_zones.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = format("${var.prefix}-private%02d", count.index + 1)
  })
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name = "${var.prefix}-ig"
  })
}

resource "aws_eip" "nat_gateway_elastic_ips" {
  count = length(var.public_subnet_cidrs)
  vpc   = true

  tags = merge(local.tags, {
    Name = format("${var.prefix}-eip%02d", count.index + 1)
  })

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat_gateway_elastic_ips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = merge(local.tags, {
    Name = format("${var.prefix}-ngw%02d", count.index + 1)
  })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = merge(local.tags, {
    Name = "${var.prefix}-public"
  })
}

resource "aws_route_table_association" "public_route_table_associations" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_tables" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }

  tags = merge(local.tags, {
    Name = format("${var.prefix}-private%02d", count.index + 1)
  })
}

resource "aws_route_table_association" "private_route_table_associations" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

# This doesn't seem to be required. (See NoIngressSecurityGroup in the original
# CloudFormation template from AWS.)
# resource "aws_security_group" "no_ingress" {
#   name        = "${var.prefix}-no-ingress"
#   description = "No ingress traffic"
#   vpc_id      = aws_vpc.vpc.id

#   tags = {
#     Name = "${var.prefix}-no-ingress"
#   }
# }

resource "aws_security_group" "mwaa" {
  name        = "airflow-security-group-${var.prefix}"
  description = "Security Group for Amazon MWAA Environment ${var.prefix}"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "airflow-security-group-${var.prefix}"
  })
}
