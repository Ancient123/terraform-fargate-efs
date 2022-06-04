# ECS Task
resource "aws_ecs_task_definition" "nginx" {
  cpu = 256 # 0.25 CPU cores
  #execution_role_arn:  role that the Amazon ECS container agent and the Docker daemon assume
  execution_role_arn       = aws_iam_role.nginx_taskexec_role.arn # Needs log permissions
  family                   = "nginx"
  memory                   = 512 # 512MB RAM
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  #task_role_arn: IAM role your Amazon ECS container task uses to make calls to other AWS services
  task_role_arn = aws_iam_role.nginx_taskexec_role.arn # Needs EFS permissions but seems to work without them?
  container_definitions = jsonencode([
    {
      name      = "nginx"
      essential = true
      image     = "nginx:alpine"
      mountPoints = [
        {
          sourceVolume  = "nginx-storage"
          containerPath = "/usr/share/nginx/html/"
          readOnly      = true
        }
      ]
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.nginx.name,
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  volume {
    name = "nginx-storage"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.nginx.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.nginx.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.default.id
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.nginx.arn
  load_balancer {
    container_name   = "nginx"
    container_port   = 80
    target_group_arn = aws_lb_target_group.nginx.arn
  }
  network_configuration {
    security_groups = [aws_security_group.task.id]
    subnets         = data.aws_subnets.default.ids
    # If you don't have a nat gateway, the task needs a public IP
    # Otherwise it will fail to start up while fetching the container image
    assign_public_ip = true
  }
}

resource "aws_cloudwatch_log_group" "nginx" {
  name = "/fargate/service/nginx"
}
