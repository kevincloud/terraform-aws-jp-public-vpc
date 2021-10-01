output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
    value = aws_subnet.private-subnets[*].id
}

output "public_subnet_id" {
    value = aws_subnet.public-subnet.id
}