variable "instance_name" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "enable_file_provisioner" {
  type    = bool
  default = false
}

variable "file_source" {
  type    = string
  default = ""
}

variable "file_destination" {
  type    = string
  default = ""
}

variable "private_key" {
  type    = string
  default = ""
}

variable "remote_exec_commands" {
  type    = list(string)
  default = []
}
