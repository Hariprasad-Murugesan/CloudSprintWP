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

# ECS Task Definition - FIXED VERSION
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

# ECS Service 
resource "aws_ecs_service" "wordpress" {
  name            = "wordpress-service-${var.environment}"
  cluster         = aws_ecs_cluster.wordpress_cluster.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = 1
  launch_type     = "FARGATE"

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

  depends_on = [
    aws_lb_listener.wordpress,
    aws_lb_target_group.wordpress
  ]

  tags = var.tags
}