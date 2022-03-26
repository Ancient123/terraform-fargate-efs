#
# HTTP from world (for Load Balancer)
#
resource "aws_security_group" "http_world" {
  name        = "http-from-world"
  description = "Full external access to http(s)"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "http_world" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.http_world.id
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "outbound_world" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.http_world.id
  to_port           = 0
  type              = "egress"
}

#
# HTTP from Load Balancer (for Task)
#
resource "aws_security_group" "task" {
  name        = "lb-to-task"
  description = "Allow load balancer to talk to task"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "task" {
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.task.id
  source_security_group_id = aws_security_group.http_world.id
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "outbound_task" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.task.id
  to_port           = 0
  type              = "egress"
}

## Allow access from world (for diagnostics)
#resource "aws_security_group_rule" "http_world_task" {
#  cidr_blocks       = ["0.0.0.0/0"]
#  from_port         = 80
#  protocol          = "tcp"
#  security_group_id = aws_security_group.task.id
#  to_port           = 80
#  type              = "ingress"
#}

#
# EFS from EFS Tagged (for EFS endpoints)
#
resource "aws_security_group" "efs" {
  name        = "efs-from-task"
  description = "Allow EFS traffic from the VPC"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "efs" {
  from_port                = 2049 #nfs/efs port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.task.id
  to_port                  = 2049 #nfs/efs port
  type                     = "ingress"
}

## Allow access from VPC (for diagnostics and loading data)
#resource "aws_security_group_rule" "efs_vpc" {
#  cidr_blocks       = [data.aws_vpc.default.cidr_block]
#  from_port         = 2049 #nfs/efs port
#  protocol          = "tcp"
#  security_group_id = aws_security_group.efs.id
#  to_port           = 2049 #nfs/efs port
#  type              = "ingress"
#}
