output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "public_subnet_az2_id" {
  value = aws_subnet.public_subnet_az2.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "private_rt_id" {
  value = aws_route_table.private_rt.id
}

output "private_subnet_cidr" {
  value = aws_subnet.private_subnet.cidr_block
}