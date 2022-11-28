output "instance_ip_addr" {
  value = aws_launch_configuration.alc_example.associate_public_ip_address
}

output "elb_dns_name" {
  value = aws_elb.elb_example.dns_name
}