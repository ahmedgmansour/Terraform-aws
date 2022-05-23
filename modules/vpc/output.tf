output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_id" {
  value = aws_subnet.public.id
}

output "private_id" {
  value = aws_subnet.private.id
}

output "ami_id" {
  value = data.aws_ssm_parameter.this.value   # hst5dm output bta3hom f main code el bekon bra module 
}


output "igw_id" {
  value = aws_internet_gateway.main-gw.id
}

output "route-public_id" {
  value = aws_route_table.main-public.id
}

# output "instance_id" {
#   value = aws_instance.example.id
# }

output "sg_id" {
  value = aws_security_group.allow-ssh.id
}

# output "ebs_id" {
#   value = aws_ebs_volume.ebs-volume-1.id
# }


output "eip_id" {
  value = aws_eip.nat.id
}


output "association_id" {
  value = aws_route_table_association.main-private-1.id
}

output "route-private_id" {
  value = aws_route_table_association.main-private-1.id
}

output "NATG_id" {
  value = aws_nat_gateway.nat-gw.id
}

