resource "aws_alb" "alb" {
  name                       = "${var.project_name}-alb"
  load_balancer_type         = "application"
  internal                   = false
  security_groups            = [var.alb_sg_id]
  subnets                    = aws_subnet.public-subnets[*].id
  idle_timeout               = 300
  drop_invalid_header_fields = true # Drop invalid headers to prevent HTTP desync attacks

  access_logs {
    bucket  = var.logs_bucket
    prefix  = "${var.project_name}/alb"
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_alb_target_group" "ecs-tg" {
  for_each    = var.ecs_services
  name        = "${var.project_name}-${each.key}-tg"
  target_type = "ip"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    enabled             = true
    interval            = 20
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.project_name}-${each.key}-alb-tg"
  }
}

resource "aws_lb_listener" "ecs-listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-tg["gateway"].arn
  }

  tags = {
    Name = "${var.project_name}-ecs-listener"
  }
}

resource "aws_lb_listener_rule" "ecs-rule" {
  for_each = {
    for key, value in var.ecs_services : key => value if key != "gateway"
  }
  listener_arn = aws_lb_listener.ecs-listener.arn
  priority     = 10 + index(keys(var.ecs_services), each.key)


  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-tg[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.path]
    }
  }

  tags = {
    Name = "${var.project_name}-${each.key}-ecs-rule"
  }
}