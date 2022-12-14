output "instance_ip_addr" {
  value = aws_launch_configuration.alc_example.associate_public_ip_address
}

output "elb_dns_name" {
  value = aws_elb.elb_example.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.aag_example.name
}

output "elb_security_group_id" {
  value = aws_security_group.elb.id
}