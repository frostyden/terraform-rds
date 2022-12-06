#Autoscaling group with 2 to 4 instances 
resource "aws_autoscaling_group" "aag_example" {
  launch_configuration = aws_launch_configuration.alc_example.id
  availability_zones   = data.aws_availability_zones.all.names

  load_balancers    = [aws_elb.elb_example.name]
  health_check_type = "ELB"

  min_size = 2
  max_size = 4

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


#After making changes to script, application does not change, troubleshoot it
  user_data = templatefile("user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  })

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
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAi3ubmdmIuisvWZ0saPz5mfiTBAKg1FCVpntoxvV2Wp fdenfrost@gmail.com"

}

data "aws_availability_zones" "all" {}

#Read db data from remote state file
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "terraform-up-and-running-state-for-denizkin"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "eu-central-1"
  }
}

# Did not work, couldn't run app on instance
# data "template_file" "user_data" {
#   //template = file("user-data.sh")
#   template = "${file("${path.module}/user-data.sh")}"

#   vars = {
#     server_port = var.server_port
#     db_address  = data.terraform_remote_state.db.outputs.address 
#     db_port     = data.terraform_remote_state.db.outputs.port 
#   }
# }

