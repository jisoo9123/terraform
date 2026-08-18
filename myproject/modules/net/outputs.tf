output "vpc_id" {
  value = aws_vpc.myVPC.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "web_sg_id" {
  description = "WEB/WAS Security Group ID"
  value       = aws_security_group.web.id
}

output "db_sg_id" {
  description = "DB Security Group ID"
  value       = aws_security_group.db.id
}
