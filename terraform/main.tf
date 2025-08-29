# ECS Cluster
resource "aws_ecs_cluster" "wordpress_cluster" {
  name = "wordpress-cluster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name = "wordpress-ecs-cluster"
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "wordpress" {
  family                   = "wordpress-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "wordpress"
    image     = "wordpress:6.4-apache"
    essential = true
    
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.wordpress.name
        awslogs-region        = var.aws_region  
        awslogs-stream-prefix = "ecs"
      }
    }

    environment = [
      {
        name  = "WORDPRESS_DB_HOST"
        value = aws_db_instance.wordpress_db.endpoint
      },
      {
        name  = "WORDPRESS_DB_NAME"
        value = "wordpress"
      },
      {
        name  = "WORDPRESS_DB_USER"
        value = var.db_username
      },
      {
        name  = "WORDPRESS_DB_PASSWORD"
        value = var.db_password
      },
      {
        name  = "WORDPRESS_AUTH_KEY"
        value = var.wp_auth_key
      },
      {
        name  = "WORDPRESS_SECURE_AUTH_KEY"
        value = var.wp_secure_auth_key
      },
      {
        name  = "WORDPRESS_LOGGED_IN_KEY"
        value = var.wp_logged_in_key
      },
      {
        name  = "WORDPRESS_NONCE_KEY"
        value = var.wp_nonce_key
      },
      {
        name  = "WORDPRESS_AUTH_SALT"
        value = var.wp_auth_salt
      },
      {
        name  = "WORDPRESS_SECURE_AUTH_SALT"
        value = var.wp_secure_auth_salt
      },
      {
        name  = "WORDPRESS_LOGGED_IN_SALT"
        value = var.wp_logged_in_salt
      },
      {
        name  = "WORDPRESS_NONCE_SALT"
        value = var.wp_nonce_salt
      },
      {
        name  = "WORDPRESS_CONFIG_EXTRA"
        value = "define('WP_DEBUG', false);"
      }
    ]
  }])

  tags = var.tags
  depends_on = [aws_db_instance.wordpress_db]
}

# ECS Service with Auto Scaling
resource "aws_ecs_service" "wordpress" {
  name            = "wordpress-service-${var.environment}"
  cluster         = aws_ecs_cluster.wordpress_cluster.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = var.desired_count
  


  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.public[*].id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wordpress.arn
    container_name   = "wordpress"
    container_port   = 80
  }

  # KEEP THIS - Auto Scaling Configuration
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [
    aws_lb_listener.wordpress,
    aws_lb_target_group.wordpress
  ]

  tags = var.tags
}

# Application Auto Scaling Target
resource "aws_appautoscaling_target" "wordpress" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.wordpress_cluster.name}/${aws_ecs_service.wordpress.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based Scale Out Policy
resource "aws_appautoscaling_policy" "scale_out_cpu" {
  name               = "wordpress-scale-out-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.wordpress.resource_id
  scalable_dimension = aws_appautoscaling_target.wordpress.scalable_dimension
  service_namespace  = aws_appautoscaling_target.wordpress.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_scale_threshold
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# Memory-based Scale Out Policy
resource "aws_appautoscaling_policy" "scale_out_memory" {
  name               = "wordpress-scale-out-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.wordpress.resource_id
  scalable_dimension = aws_appautoscaling_target.wordpress.scalable_dimension
  service_namespace  = aws_appautoscaling_target.wordpress.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_scale_threshold
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}