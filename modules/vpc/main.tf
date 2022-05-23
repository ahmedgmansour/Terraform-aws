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
  vpc = true
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "main-private" {
  vpc_id = aws_vpc.vpc.id
}  


resource "aws_instance" "example" {
 vpc_id     = aws_vpc.vpc.id
}

resource "aws_security_group" "allow-ssh" {
vpc_id      = aws_vpc.vpc.id
}

resource "aws_ebs_volume" "ebs-volume-1" {
vpc_id      = aws_vpc.vpc.id
}


data "aws_ssm_parameter" "this" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2" # to get AMI ID of the latest linux2 machine image
}


resource "aws_route_table_association" "main-private-1-a" {
vpc_id      = aws_vpc.vpc.id
}

resource "aws_key_pair" "webserver-key" {
  key_name   = "webserver-key"
  public_key = file("~/.ssh/id_rsa.pub")
}