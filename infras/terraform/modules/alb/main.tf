resource "aws_alb" "jenkins_alb" {
  name               = "${var.project_name}-jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.public_subnet_id, var.public_subnet_az2_id]
  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-alb" }
  )
}

resource "aws_lb_target_group" "jenkins_controller_tg" {
  name        = "${var.project_name}-controller-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/login"
    port                = "8080"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.project_name}-controller-tg" }
  )
}

resource "aws_lb_listener" "jenkins_http_listener" {
  load_balancer_arn = aws_alb.jenkins_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "github_webhook" {
  listener_arn = aws_lb_listener.jenkins_http_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["/github-webhook/"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_controller_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "jenkins_controller_attachment" {
  target_group_arn = aws_lb_target_group.jenkins_controller_tg.arn
  target_id        = var.controller_instance_id
  port             = 8080
}