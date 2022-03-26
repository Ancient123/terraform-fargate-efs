# Create load balancer
resource "aws_lb" "nginx" {
  name               = "nginx-ecs-test"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_world.id]
  subnets            = data.aws_subnets.default.ids
}

# Create target group to connect services to
resource "aws_lb_target_group" "nginx" {
  name                 = "nginx"
  deregistration_delay = 30
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = data.aws_vpc.default.id
}

# Create listener for HTTP
#   and attach the target group as the default action
resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.nginx.id
    type             = "forward"
  }
}
