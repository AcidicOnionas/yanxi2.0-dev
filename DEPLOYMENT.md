# Yanxi Platform Deployment Guide

## Overview
This guide will help you deploy the Yanxi education platform (Vue.js frontend + Spring Boot API + MySQL database) on a single Ubuntu 22.04 DigitalOcean droplet.

## Prerequisites
- Ubuntu 22.04 droplet running
- SSH access to the droplet
- Domain name pointed to your droplet IP (api.yanxi.com)

## Step 1: Initial Server Setup

### Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### Install Essential Packages
```bash
sudo apt install -y curl wget unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release
```

## Step 2: Install Java 17
```bash
sudo apt install -y openjdk-17-jdk
echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" | sudo tee -a /etc/environment
source /etc/environment
java -version
```

## Step 3: Install and Configure MySQL
```bash
# Install MySQL
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL (run mysql_secure_installation or do manually)
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'YanxiDB2024!';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Create Yanxi database and user
sudo mysql -u root -pYanxiDB2024! -e "CREATE DATABASE yanxi_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -u root -pYanxiDB2024! -e "CREATE USER 'yanxi_user'@'localhost' IDENTIFIED BY 'YanxiUser2024!';"
sudo mysql -u root -pYanxiDB2024! -e "GRANT ALL PRIVILEGES ON yanxi_db.* TO 'yanxi_user'@'localhost';"
sudo mysql -u root -pYanxiDB2024! -e "FLUSH PRIVILEGES;"
```

## Step 4: Install Node.js and npm
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
```

## Step 5: Install Nginx
```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

## Step 6: Install SSL Certificate Tool
```bash
sudo apt install -y certbot python3-certbot-nginx
```

## Step 7: Create Application Directories
```bash
sudo mkdir -p /opt/yanxi/{api,web,uploads,logs}
sudo useradd -r -s /bin/false yanxi
sudo chown -R yanxi:yanxi /opt/yanxi
```

## Step 8: Configure Firewall
```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable
sudo ufw status
```

## Step 9: Set Up Database Schema
```bash
# Connect to MySQL and create tables
mysql -u yanxi_user -pYanxiUser2024! yanxi_db
```

Then run the SQL from `db_schema.sql` file.

## Step 10: Deploy Spring Boot API
1. Transfer your `yanxi-api` folder to the server
2. Update `application.yml` with production database settings
3. Build and run the API:
```bash
cd yanxi-api
./mvnw clean package -DskipTests
sudo cp target/*.jar /opt/yanxi/api/yanxi-api.jar
sudo chown yanxi:yanxi /opt/yanxi/api/yanxi-api.jar
```

4. Create systemd service for the API
5. Start the service

## Step 11: Deploy Vue.js Frontend
1. Transfer your `yanxi-web` folder to the server
2. Update API endpoints in Vue.js config
3. Build and deploy:
```bash
cd yanxi-web
npm install
npm run build
sudo cp -r dist/* /opt/yanxi/web/
sudo chown -R yanxi:yanxi /opt/yanxi/web
```

## Step 12: Configure Nginx
Create nginx configuration to:
- Serve Vue.js frontend
- Proxy API requests to Spring Boot
- Handle SSL termination

## Step 13: Set Up SSL Certificate
```bash
sudo certbot --nginx -d api.yanxi.com
```

## Step 14: Test Everything
- Frontend: https://api.yanxi.com
- API: https://api.yanxi.com/api/health
- Database connectivity

## Default Login Credentials
- Username: `admin` / Password: `password`
- Username: `teacher1` / Password: `password`  
- Username: `student1` / Password: `password`

## Useful Commands
```bash
# Check API service status
sudo systemctl status yanxi-api

# View API logs
sudo journalctl -u yanxi-api -f

# Check nginx status
sudo systemctl status nginx

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

## Next Steps
After completing these steps, you'll have:
- ✅ Yanxi API running on port 8080
- ✅ Vue.js frontend served by Nginx
- ✅ MySQL database with proper schema
- ✅ SSL certificate configured
- ✅ Domain pointing to your application

Let me know which step you'd like to start with! 