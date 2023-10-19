# db instance 확인용
output "db_hostname" {
  description = "RDS instance hostname"
  value = aws_db_instance.tf-db.address
}