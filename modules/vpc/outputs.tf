#-----vpc/outputs.tf-----
#=========================

output "public_subnets_one" {
  value = aws_subnet.tf_public_subnet1.id
}

output "public_subnets_two" {
  value = aws_subnet.tf_public_subnet2.id
}


output "public_sg" {
  value = aws_security_group.tf_public_sg.id
}

output "subnet_ips_one" {
  value = aws_subnet.tf_public_subnet1.cidr_block
}

output "subnet_ips_two" {
  value = aws_subnet.tf_public_subnet2.cidr_block
}
