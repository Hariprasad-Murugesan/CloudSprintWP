# Create SNS Topic for notifications
resource "aws_sns_topic" "wordpress_alerts" {
  name = "wordpress-ecs-alerts"
}

# Email subscription to SNS topic
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.wordpress_alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"  # Replace with your email
}

# CloudWatch Alarm for High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "wordpress-high-cpu"
  alarm_description   = "CPU utilization too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    ClusterName = aws_ecs_cluster.wordpress_cluster.name
    ServiceName = aws_ecs_service.wordpress.name
  }

  alarm_actions = [aws_sns_topic.wordpress_alerts.arn]
}

# CloudWatch Alarm for High Memory
resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "wordpress-high-memory"
  alarm_description   = "Memory utilization too high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.wordpress_cluster.name
    ServiceName = aws_ecs_service.wordpress.name
  }

  alarm_actions = [aws_sns_topic.wordpress_alerts.arn]
}

# CloudWatch Alarm for Service Health
resource "aws_cloudwatch_metric_alarm" "service_unhealthy" {
  alarm_name          = "wordpress-service-unhealthy"
  alarm_description   = "ECS service is unhealthy"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnhealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0

  dimensions = {
    TargetGroup  = aws_lb_target_group.wordpress.arn_suffix
    LoadBalancer = aws_lb.wordpress.arn_suffix
  }

  alarm_actions = [aws_sns_topic.wordpress_alerts.arn]
}