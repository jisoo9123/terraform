data "aws_availability_zones" "available" {
  state = "available"
}

# =========================================================
# VPC
# =========================================================

resource "aws_vpc" "myVPC" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "mini2-vpc"
  }
}

# =========================================================
# Internet Gateway
# =========================================================

resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "mini2-igw"
  }
}

# =========================================================
# Public Subnet x2
# =========================================================

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "mini2-public-${count.index + 1}"
  }
}

# =========================================================
# Private Subnet x2
# =========================================================

resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "mini2-private-${count.index + 1}"
  }
}

# =========================================================
# Public Route Table
# =========================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "mini2-public-rt"
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myIGW.id
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# =========================================================
# NAT Gateway
# =========================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "mini2-nat-eip"
  }
}

resource "aws_nat_gateway" "myNAT" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.myIGW
  ]

  tags = {
    Name = "mini2-nat"
  }
}

# =========================================================
# Private Route Table
# =========================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "mini2-private-rt"
  }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.myNAT.id
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# =========================================================
# Security Group - ALB
# =========================================================

resource "aws_security_group" "alb" {
  name        = "mini2-alb-sg"
  description = "Security Group for ALB"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mini2-alb-sg"
  }
}

# =========================================================
# Security Group - WEB/WAS
# =========================================================

resource "aws_security_group" "web" {
  name        = "mini2-web-sg"
  description = "Security Group for WEB/WAS"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mini2-web-sg"
  }
}

# =========================================================
# Security Group - DB
# =========================================================

resource "aws_security_group" "db" {
  name        = "mini2-db-sg"
  description = "Security Group for DB"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description     = "MySQL from WEB/WAS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mini2-db-sg"
  }
}
