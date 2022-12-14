module "db_mysql" {
  source = "../../../modules/data-stores/mysql"

  db_storage = 5
  db_instance_class = "db.t2.micro"
  db_name = "stage_mysql_database"
  db_password = var.stage_db_password

  providers = {
    aws = aws.euc1
   }
}