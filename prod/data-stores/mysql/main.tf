module "db_mysql" {
  source = "../../../modules/data-stores/mysql"

  db_storage = 5
  db_instance_class = "db.t2.micro"
  db_name = "prod_mysql_database"
  db_password = var.prod_db_password

}