output "network_vpc_id" {
  value = aws_vpc.cloud_network.id
}

output "private_subnet_ids" {
  value = aws_subnet.cloud_network_private.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.cloud_network_public.*.id
}

output "public_sg" {
  value = aws_security_group.cloud_network_public.id
}
