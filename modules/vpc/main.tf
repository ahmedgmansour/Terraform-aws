provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
}



resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "nat" {

}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main-public-1.id
  depends_on    = [aws_internet_gateway.main-gw]  
}

resource "aws_route_table" "main-private" {
  vpc_id = aws_vpc.vpc.id
}  


resource "aws_security_group" "allow-ssh" {
 vpc_id      = aws_vpc.vpc.id
}

# resource "aws_ebs_volume" "ebs-volume-1" {
#  vpc_id      = aws_vpc.vpc.id
# }


data "aws_ssm_parameter" "this" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2" # to get AMI ID of the latest linux2 machine image
}


resource "aws_route_table_association" "main-private-1-a" {
  subnet_id      = aws_subnet.main-private-1.id
  route_table_id = aws_route_table.main-private.id
}

