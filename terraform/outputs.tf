output "alb_dns_name" {
  value = aws_lb.wordpress.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.wordpress_db.endpoint
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.wordpress_cluster.name
}

output "ecs_service_status" {
  description = "ECS service status information"
  value = {
    service_name    = aws_ecs_service.wordpress.name
    cluster_name    = aws_ecs_service.wordpress.cluster
    desired_count   = aws_ecs_service.wordpress.desired_count
    task_definition = aws_ecs_service.wordpress.task_definition
  }
}

# Add these outputs to monitor your setup
output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = aws_sns_topic.wordpress_alerts.arn
}

output "auto_scaling_target" {
  description = "Auto scaling target resource ID"
  value       = aws_appautoscaling_target.wordpress.resource_id
}

output "cloudwatch_alarms" {
  description = "List of CloudWatch alarm names"
  value = [
    aws_cloudwatch_metric_alarm.high_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.high_memory.alarm_name,
    aws_cloudwatch_metric_alarm.service_unhealthy.alarm_name
  ]
}