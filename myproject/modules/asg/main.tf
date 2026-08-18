# =========================================================
# Auto Scaling Group
# =========================================================

resource "aws_autoscaling_group" "web" {
  name = "mini2-web-asg"

  min_size         = 2
  max_size         = 2
  desired_capacity = 2

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "mini2-web-asg"
    propagate_at_launch = true
  }
}
