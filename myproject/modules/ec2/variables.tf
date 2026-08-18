variable "private_subnet_ids" {
  description = "Private subnet IDs for WEB/WAS"
  type        = list(string)
}

variable "web_sg_id" {
  description = "Security Group ID for WEB/WAS"
  type        = string
}

variable "db_endpoint" {
  description = "Aurora DB cluster endpoint"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}
