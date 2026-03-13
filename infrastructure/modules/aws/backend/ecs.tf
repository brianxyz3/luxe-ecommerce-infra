resource "aws_ecs_cluster" "backend" {
  name = "${var.project_name}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.env
  }
}

resource "aws_ecs_task_definition" "backend" {
  for_each                 = var.ecs_services
  family                   = "${var.project_name}-${each.key}-${var.env}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.exec_role
  task_role_arn            = var.exec_role


  container_definitions = jsonencode([
    {
      name = "${var.project_name}-${each.key}"

      # Stable public placeholder "Hello World" image
      image = "public.ecr.aws/docker/library/hello-world:latest"
      portMappings = [
        {
          essential     = true
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs-log-group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])



  # IMPORTANT: Prevents Terraform drift from service CI/CD Pipeline job run
  # Stops terrafom from reverting the image back to "hello-world" once your CI/CD pipeline deploys your actual app image.
  lifecycle {
    ignore_changes = [container_definitions]
  }

  depends_on = [aws_cloudwatch_log_group.ecs-log-group]


  tags = {
    Name        = "${var.project_name}-backend-service"
    Environment = var.env
  }
}

resource "aws_ecs_service" "backend" {
  for_each        = var.ecs_services
  name            = "${var.project_name}-${each.key}-${var.env}-service"
  cluster         = aws_ecs_cluster.backend.id
  task_definition = aws_ecs_task_definition.backend[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    assign_public_ip = true # False is the default. If you want your service to be directly accessible over the internet via the public ip use true.
    subnets          = var.subnet_ids[*]
    security_groups  = [var.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = var.tg_arn[each.key]
    container_name   = "${var.project_name}-${each.key}"
    container_port   = var.container_port
  }

  tags = {
    Name        = "${var.project_name}-backend-service"
    Environment = var.env
  }
}

resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 14
}
