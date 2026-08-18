output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.web.id
}

output "launch_template_arn" {
  description = "Launch Template ARN"
  value       = aws_launch_template.web.arn
}
