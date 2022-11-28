# resource "aws_instance" "example" {
#   ami           = "ami-06148e0e81e5187c8"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [ "${aws_security_group.instance.id}" ]

#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello World" > index.html
#               nohup busybox httpd -f -p ${var.server_port} &
#               EOF

#   tags = {
#     "name" = "terraform-example"
#   }
# }

#Autoscaling group with 2 to 10 instances 
resource "aws_autoscaling_group" "aag_example" {
  launch_configuration = aws_launch_configuration.alc_example.id
  availability_zones   = data.aws_availability_zones.all.names

  load_balancers    = [aws_elb.elb_example.name]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }

}

#Launch configuration for autoscaling group of instances
resource "aws_launch_configuration" "alc_example" {
  image_id        = "ami-06148e0e81e5187c8"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Security group allow from all IPs to port 8080"
    from_port        = "${var.server_port}"
    to_port          = "${var.server_port}"
    protocol         = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  lifecycle {
    create_before_destroy = true
  }
}

# Load balancer
resource "aws_elb" "elb_example" {
  name               = "terraform-asg-example"
  availability_zones = data.aws_availability_zones.all.names
  security_groups    = [aws_security_group.elb.id]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}

#Security group for load balancer
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Ingress rules for load balancer for autoscaling group"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 80
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Egress rules for load balancer for autoscaling group"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
}

#Public key to access the instance
resource "aws_key_pair" "public_key" {
  key_name   = "denizkin-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCe8Wi0DVJpp/UhrSq6xACziaSZPniZsonNOuGIKutCCWJvTH8TpQh6vq/VyQdFXY6EtX0qoWUIrx65X6db1IDAS7T6PtiJQ3RkLnMyJn60E7Jsr9PlwkYWa3id6ZNMK3Ecih11QYgZhWC/u2+kbTEmzpX/AJwGjprxYiOsCVpbjPRMI3H8xx/5KaS2bczITgZuzeED7qTSNdF48MGiPguuBfI4KaEpKaNxQidgDpq1MTGpj+QTd3ypwxmEqJ5aMxNXLCv+gMSJztEHd9nbd7jkSisjBEFsiscY4/n1ind9EdkENGJwjGWhBAs9GztkA2AtMM6J02dj6QYKxHW672Ntiuh9AWdrlaLmPJVx1Oi4tFJjR3A+Il8zuqSwaslrM6jf22R11kLDAbSxRpF9Bu/Ry2Ef8NUrc9EvUJthPtRlobv2t6jGCjXUpbyZSXst4le0qFlOxHM4KsT3o6A21kVs2DGRyukEiPrk+fB0fBWSO5bP1/WHN4ITs0mV4FAG4y0= frosty@Denizs-MacBook-Pro-2.local"

}

data "aws_availability_zones" "all" {}