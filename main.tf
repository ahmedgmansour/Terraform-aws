provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

# Internet VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"        #you can have multiple instances on one phsical piece of hardware 
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "main-public-1" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1"

  tags = {
    Name = "main-public-1"
  }
}



resource "aws_subnet" "main-private-1" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1"

  tags = {
    Name = "main-private-1"
  }
}


# Internet GW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "igw"
  }
}

# route tables
resource "aws_route_table" "main-public" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.igw_id
  }

  tags = {
    Name = "main-public-1"
  }
}

# route associations public
resource "aws_route_table_association" "main-public-1-a" {
  subnet_id      = module.vpc.public_id
  route_table_id = module.vpc.route-public_id
}



# nat gw
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = module.vpc.eip_id
  subnet_id     = module.vpc.public_id
  depends_on    = [module.vpc.igw_id]
}

# VPC setup for NAT
resource "aws_route_table" "main-private" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.vpc.NATG_id
  }

  tags = {
    Name = "main-private-1"
  }
}

# route associations private
resource "aws_route_table_association" "main-private-1-a" {
  subnet_id      = module.vpc.private_id
  route_table_id = module.vpc.route-private_id
}




#web server
resource "aws_instance" "example" {
  ami                         = module.vpc.ami_id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.webserver-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = module.vpc.public_id
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install httpd && sudo systemctl start httpd",
      "echo '<h1><center>My Test Website With Help From Terraform Provisioner</center></h1>' > index.html",
      "sudo mv index.html /var/www/html/"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
  tags = {
    Name = "webserver"
  }
}


#Create SG for allowing TCP/80 & TCP/22
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow TCP/80 & TCP/22"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "Webserver-Public-IP" {
  value = aws_instance.example.public_ip
}