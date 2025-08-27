output "wordpress_url" {
  description = "URL to access WordPress"
  value       = "http://${aws_instance.wordpress.public_ip}"
}

output "public_ip" {
  description = "Public IP address of WordPress instance"
  value       = aws_instance.wordpress.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i your-key.pem ec2-user@${aws_instance.wordpress.public_ip}"
}