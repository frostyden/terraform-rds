variable "server_port" {
  description = "port that server will use for http"
  default     = 8080

}

variable "cluster_name" {
  description = "Cluster name to use for all cluster resources"
}

variable "db_remote_state_bucket" {
  description = "Name of S3 bucket for db remote state"
}

variable "db_remote_state_key" {
  description = "Path for db's remote state in S3"
}

variable "instance_type" {
  description = "Type of EC2 Instances to run (e.g. t2.micro)"
}

variable "min_size" {
  description = "Minimum number of EC2 Instances in the ASG"
}

variable "max_size" {
  description = "Maximum number of EC2 Instances in the ASG"
}
