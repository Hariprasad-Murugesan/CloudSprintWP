#!/bin/bash
# Update system and install dependencies
yum update -y
yum install -y docker

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create WordPress directory and mount EBS volume
mkdir -p /var/www/html
# Note: The EBS volume will be mounted at /dev/sdh by Terraform
# We need to format and mount it if not already done

# Check if /dev/sdh exists and mount it
if [ -b /dev/sdh ]; then
    # Check if the disk is formatted
    if ! blkid /dev/sdh; then
        mkfs -t ext4 /dev/sdh
    fi
    mount /dev/sdh /var/www/html
    echo "/dev/sdh /var/www/html ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# Create WordPress directory
cd /var/www/html

# Create correct docker-compose.yml
cat > docker-compose.yml << 'EOL'
version: '3.8'

services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    networks:
      - wpsite

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - '80:80'
    restart: always
    volumes:
      - /var/www/html:/var/www/html
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
    networks:
      - wpsite

networks:
  wpsite:

volumes:
  db_data:
EOL

# Start the WordPress stack
docker-compose up -d

# Print completion message
echo "WordPress setup completed! Access your site at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/"