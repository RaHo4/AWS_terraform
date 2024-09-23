variable "allocated_storage" {
  type        = number
  default     = 20
  description = "Размер хранилища для RDS (в GB)"
}

variable "engine" {
  type        = string
  description = "Движок базы данных (например, mysql, postgres, mariadb)"
}

variable "instance_class" {
  type        = string
  description = "Класс инстанса (например, db.t3.micro)"
}

variable "db_name" {
  type        = string
  description = "Имя базы данных"
}

variable "username" {
  type        = string
  description = "Имя пользователя для базы данных"
}

variable "password" {
  type        = string
  description = "Пароль для PostgreSQL"
  sensitive   = true
}

variable "parameter_group_name" {
  type        = string
  default     = "default"
  description = "Имя группы параметров для базы данных"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Пропустить ли финальный снимок при удалении базы данных"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Будет ли RDS публично доступной"
}

variable "db_subnet_group" {
  description = "The name of the DB subnet group to associate with the DB instance."
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs for the DB subnet group."
  type        = list(string)
}


variable "vpc_security_group_ids" {
  type        = list(string)
  description = "ID security groups для RDS"
}

variable "apply_immediately" {
  type        = bool
  default     = true
  description = "Применять изменения немедленно или во время окна обслуживания"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Количество дней для хранения резервных копий"
}

variable "availability_zone" {
  type        = string
  description = "Зона доступности для RDS"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Поддержка Multi-AZ для RDS"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Теги для инстанса RDS"
}

variable "option_groups" {
  type = list(object({
    name = string
  }))
  default     = []
  description = "Опции для движка базы данных (необязательно)"
}
