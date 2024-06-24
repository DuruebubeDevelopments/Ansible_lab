output "vpc-id" {
  value = aws_vpc.vpc.id
}
output "instance-ip" {
  value = aws_instance.instance.public_ip
}