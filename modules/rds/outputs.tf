output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
  description = "Endpoint для подключения к RDS"
}

output "rds_arn" {
  value = aws_db_instance.this.arn
  description = "ARN RDS инстанса"
}

output "rds_instance_id" {
  value = aws_db_instance.this.id
  description = "ID RDS инстанса"
}
