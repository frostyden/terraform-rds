module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"

    cluster_name = "webservers-stage"
    db_remote_state_bucket = "terraform-up-and-running-state-for-denizkin"
    db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
    #db_region = provider.aws.region

    instance_type = "t2.micro"
    min_size = 2
    max_size = 2

}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type = "ingress"
  security_group_id = module.webserver_cluster.elb_security_group_id
  description      = "Testing ingress rule for load balancer that is for autoscaling group"
  
  from_port        = 12345
  protocol         = "tcp"
  to_port          = 12345
  cidr_blocks = ["0.0.0.0/0"]
}