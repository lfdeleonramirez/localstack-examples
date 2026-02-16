output "vpc_id" { value = aws_vpc.vpc_main.id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "vpc_cidr" { value = aws_vpc.vpc_main.cidr_block }