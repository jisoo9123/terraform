# =========================================================
# Target Group
# =========================================================

resource "aws_lb_target_group" "web" {
  name     = "mini2-web-tg"
  port     = 80
  protocol = "HTTP"

  vpc_id = var.vpc_id

  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "mini2-web-tg"
  }
}

# =========================================================
# Application Load Balancer
# =========================================================

resource "aws_lb" "web" {
  name               = "mini2-web-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.alb_sg_id
  ]

  subnets = var.public_subnet_ids

  tags = {
    Name = "mini2-web-alb"
  }
}

# =========================================================
# ALB Listener
# =========================================================

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
