variable "private_subnet_ids" {
  description = "Private subnet IDs for DB"
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security Group ID for DB"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_username" {
  description = "Master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}
