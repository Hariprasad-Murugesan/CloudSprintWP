data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-sg-${var.environment}"
  description = "Security group for WordPress instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound traffic"
  }

  tags = {
    Environment = var.environment
    Name        = "wordpress-security-group"
  }
}


resource "aws_instance" "wordpress" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]
  key_name               = var.key_name
  user_data              = filebase64("user-data.sh")

  tags = {
    Name        = "wordpress-${var.environment}"
    Environment = var.environment
  }
}

# Add EBS volume for WordPress data
resource "aws_ebs_volume" "wordpress_data" {
  availability_zone = aws_instance.wordpress.availability_zone
  size              = 20
  type              = "gp3"
  tags = {
    Name = "wordpress-data"
  }
}


resource "aws_volume_attachment" "wordpress_attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.wordpress_data.id
  instance_id = aws_instance.wordpress.id
}