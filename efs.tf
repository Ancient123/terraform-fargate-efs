# Create EFS File System
resource "aws_efs_file_system" "nginx" {
  encrypted = true
  lifecycle {
    prevent_destroy = true
  }
}

# Create an access point
resource "aws_efs_access_point" "nginx" {
  file_system_id = aws_efs_file_system.nginx.id
}

# Create a mount target in every subnet (one per AZ in the VPC)
resource "aws_efs_mount_target" "nginx" {
  for_each        = toset(data.aws_subnets.default.ids)
  file_system_id  = aws_efs_file_system.nginx.id
  security_groups = [aws_security_group.efs.id]
  subnet_id       = each.value
}
