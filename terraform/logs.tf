# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/ecs/wordpress-${var.environment}"
  retention_in_days = 30

  tags = {
    Environment = var.environment
  }
}