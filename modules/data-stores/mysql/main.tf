resource "aws_db_instance" "example" {
  engine = "mysql"
  allocated_storage = var.db_storage
  instance_class = var.db_instance_class
  db_name = var.db_name
  username = "admin"
  password = var.db_password
}