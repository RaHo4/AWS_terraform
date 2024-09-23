variable "ssh_allowed_ip" {
  description = "IP address allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0" 
}
