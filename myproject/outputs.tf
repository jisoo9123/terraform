output "vpc_id" {
  description = "VPC ID"
  value       = module.net.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.net.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.net.private_subnet_ids
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = module.net.alb_sg_id
}

output "web_sg_id" {
  description = "WEB/WAS Security Group ID"
  value       = module.net.web_sg_id
}

output "db_sg_id" {
  description = "DB Security Group ID"
  value       = module.net.db_sg_id
}

output "db_cluster_endpoint" {
  description = "Aurora MySQL cluster endpoint"
  value       = module.db.cluster_endpoint
  sensitive   = true
}

output "db_reader_endpoint" {
  description = "Aurora MySQL reader endpoint"
  value       = module.db.reader_endpoint
  sensitive   = true
}

output "launch_template_id" {
  description = "WEB Launch Template ID"
  value       = module.ec2.launch_template_id
}

output "launch_template_arn" {
  description = "WEB Launch Template ARN"
  value       = module.ec2.launch_template_arn
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = module.alb.target_group_arn
}

output "target_group_name" {
  description = "Target Group name"
  value       = module.alb.target_group_name
}

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "Auto Scaling Group ARN"
  value       = module.asg.autoscaling_group_arn
}

