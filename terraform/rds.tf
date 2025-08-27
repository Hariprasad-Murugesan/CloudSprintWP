# RDS Database Subnet Group
resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-db-subnet-group-${var.environment}"
  subnet_ids = aws_subnet.private[*].id  # Corrected to flat list

  tags = {
    Environment = var.environment
  }
}

# RDS Database Instance
resource "aws_db_instance" "wordpress_db" {
  identifier             = "wordpress-db-${var.environment}"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "wordpress"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name        = "wordpress-db-${var.environment}"
    Environment = var.environment
  }
}