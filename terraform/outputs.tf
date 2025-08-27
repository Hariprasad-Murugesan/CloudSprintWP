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