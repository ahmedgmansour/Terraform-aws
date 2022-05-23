module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

# nat gw
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = module.vpc.aws_eip.nat
  subnet_id     = module.vpc.aws_subnet.public
  depends_on    = [module.vpc.aws_internet_gateway.main-gw]
}

# VPC setup for NAT
resource "aws_route_table" "main-private" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.vpc.aws_nat_gateway.nat-gw
  }

  tags = {
    Name = "main-private-1"
  }
}

# route associations private
resource "aws_route_table_association" "main-private-1-a" {
  subnet_id      = module.vpc.aws_subnet.private
  route_table_id = module.vpc.aws_route_table.main-private
}


