# Bitwise Deployment

Comprehensive deployment configuration and automation for the Bitwise learning platform on AWS EC2.

## Overview

This repository contains Docker Compose configurations, deployment scripts, and CI/CD workflows for deploying the Bitwise application stack on AWS EC2. The deployment uses Traefik as a reverse proxy with automatic SSL certificate management via Let's Encrypt.

## Architecture

The deployment consists of three main services:

- **Traefik** - Reverse proxy and SSL termination
- **Backend** - NestJS API server (Node.js)
- **Frontend** - React application (served via Nginx)

## Prerequisites

### AWS Infrastructure
- AWS EC2 instance (Ubuntu 22.04 LTS recommended)
- Minimum t2.medium instance (2 vCPU, 4GB RAM)
- At least 20GB of storage
- Elastic IP address assigned to the instance
- Domain name pointed to the Elastic IP (for SSL)

### Security Group Configuration

Your EC2 security group must allow the following inbound traffic:

| Port | Protocol | Source | Purpose |
|------|----------|--------|----------|
| 22 | TCP | Your IP | SSH access |
| 80 | TCP | 0.0.0.0/0 | HTTP (redirects to HTTPS) |
| 443 | TCP | 0.0.0.0/0 | HTTPS |
| 8080 | TCP | Your IP | Traefik dashboard (optional) |

### Server Requirements
- Docker Engine (v24.0 or higher)
- Docker Compose V2 plugin
- Git
- SSH access with key-based authentication

### GitHub Secrets

For automated deployments via GitHub Actions, configure these repository secrets:

| Secret Name | Description | Example |
|-------------|-------------|----------|
| `EC2_HOST` | EC2 instance public IP or domain | `47.129.118.12` |
| `EC2_USER` | SSH username | `ubuntu` |
| `EC2_SSH_KEY` | Private SSH key content | Contents of `.pem` file |

## Directory Structure

The project follows a multi-repository structure. On your EC2 server, the directory layout should be:

```
~/bitwise/
├── bitwise-deploy/
│   └── deploy/
│       └── aws/
│           ├── docker-compose.yml    # Main deployment config
│           ├── deploy.sh             # Deployment automation script
│           ├── letsencrypt/          # SSL certificates (auto-created)
│           ├── README.md             # AWS-specific documentation
│           ├── SECRETS_MANAGEMENT.md # Environment variables guide
│           └── TROUBLESHOOTING.md    # Common issues and solutions
├── bitwise-server/
│   ├── .env                          # Backend environment variables
│   ├── Dockerfile
│   └── src/
└── bitwise-ui/
    ├── .env                          # Frontend environment variables (if needed)
    ├── Dockerfile
    └── src/
```

## Initial Setup

### 1. Prepare EC2 Instance

SSH into your EC2 instance:

```bash
ssh -i "path/to/your-key.pem" ubuntu@<your-ec2-ip>
```

### 2. Install Docker and Docker Compose

```bash
# Update package index
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Install Docker Compose plugin
sudo apt-get install -y docker-compose-plugin

# Add user to docker group (to run without sudo)
sudo usermod -aG docker $USER

# Logout and login again for group changes to take effect
exit
```

Verify installation:

```bash
docker --version
docker compose version  # Note: space, not hyphen
```

### 3. Clone Repositories

```bash
# Create project directory
mkdir -p ~/bitwise
cd ~/bitwise

# Clone all three repositories
git clone https://github.com/One-Team-One-Goal/bitwise-deploy.git
git clone https://github.com/One-Team-One-Goal/bitwise-server.git
git clone https://github.com/One-Team-One-Goal/bitwise-ui.git
```

### 4. Configure Environment Variables

**Backend Environment (.env):**

```bash
cd ~/bitwise/bitwise-server
nano .env
```

Add the following variables:

```env
# Node Environment
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# Database Configuration
DATABASE_URL="postgresql://username:password@host:5432/database"
DIRECT_URL="postgresql://username:password@host:5432/database"

# Authentication
JWT_SECRET="your-secure-random-string-here"

# AI Services
GOOGLE_AI_API_KEY="your-google-ai-key"
GROQ_API_KEY="your-groq-api-key"

# Supabase
SUPABASE_URL="your-supabase-url"
SUPABASE_KEY="your-supabase-key"

# CORS
FRONTEND_URL="https://bitwise.live"
```

**Frontend Environment (.env):**

```bash
cd ~/bitwise/bitwise-ui
nano .env
```

Add:

```env
VITE_API_URL="https://bitwise.live/api"
VITE_SUPABASE_URL="your-supabase-url"
VITE_SUPABASE_ANON_KEY="your-supabase-anon-key"
```

### 5. Make Deploy Script Executable

```bash
cd ~/bitwise/bitwise-deploy/deploy/aws
chmod +x deploy.sh
```

### 6. Initial Deployment

```bash
cd ~/bitwise/bitwise-deploy/deploy/aws
./deploy.sh
```

This script will:
- Create necessary directories
- Set up SSL certificate storage
- Pull latest code from all repositories
- Build Docker images
- Start all containers
- Configure SSL certificates automatically

### 7. Verify Deployment

Check container status:

```bash
cd ~/bitwise/bitwise-deploy/deploy/aws
docker compose ps
```

All three services should show "Up" status.

View logs:

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f traefik
```

Access your application:
- Frontend: `https://bitwise.live` or `https://www.bitwise.live`
- Backend API: `https://bitwise.live/api`
- Traefik Dashboard: `http://<your-ec2-ip>:8080` (if enabled)

## GitHub Actions Automated Deployment

### How It Works

When you push to the `main` branch of either `bitwise-ui` or `bitwise-server`, GitHub Actions will:

1. Connect to your EC2 instance via SSH
2. Navigate to the deployment directory
3. Execute the `deploy.sh` script
4. Pull latest changes from all repositories
5. Rebuild and restart containers with zero downtime

### Troubleshooting GitHub Actions Failures

#### Common Issues and Solutions

**1. SSH Connection Failed**

Error: `Permission denied (publickey)` or `Connection timeout`

**Solution:**
- Verify `EC2_HOST` secret contains the correct IP/domain
- Ensure `EC2_SSH_KEY` contains the complete private key (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`)
- Check EC2 security group allows SSH (port 22) from GitHub Actions IP ranges
- Verify the SSH key matches the one configured in EC2

**2. Deploy Script Not Found**

Error: `No such file or directory: deploy.sh`

**Solution:**
```bash
# SSH to server and verify structure
cd ~/bitwise/bitwise-deploy/deploy/aws
ls -la deploy.sh

# If missing, pull the latest deployment repo
cd ~/bitwise/bitwise-deploy
git pull origin main
```

**3. Permission Denied Running Script**

Error: `Permission denied: ./deploy.sh`

**Solution:**
```bash
cd ~/bitwise/bitwise-deploy/deploy/aws
chmod +x deploy.sh
```

**4. Docker Compose Command Not Found**

Error: `docker-compose: command not found` or `KeyError: 'ContainerConfig'`

**Solution:**
```bash
# Install Docker Compose V2
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

# Verify installation
docker compose version
```

The `deploy.sh` script automatically handles both `docker compose` (V2) and `docker-compose` (V1).

**5. Git Pull Fails**

Error: `Could not resolve host: github.com` or `Authentication failed`

**Solution:**
```bash
# Ensure EC2 can access GitHub
ssh -i "your-key.pem" ubuntu@<ec2-ip>
ping github.com

# If using private repositories, set up SSH keys or deploy tokens
```

### Manual Deployment

If GitHub Actions fails and you need to deploy manually:

```bash
# SSH to server
ssh -i "your-key.pem" ubuntu@<ec2-ip>

# Run deployment
cd ~/bitwise/bitwise-deploy/deploy/aws
./deploy.sh
```

## Updating the Application

### Via GitHub Actions (Automatic)

Simply push to the `main` branch:

```bash
git push origin main
```

GitHub Actions will automatically deploy the changes.

### Manual Update

SSH to server and run:

```bash
cd ~/bitwise/bitwise-deploy/deploy/aws
./deploy.sh
```

### Update Specific Service Only

```bash
cd ~/bitwise/bitwise-deploy/deploy/aws

# Update and rebuild specific service
docker compose up -d --build --no-deps backend
# or
docker compose up -d --build --no-deps frontend
```

## Maintenance

### View Logs

```bash
cd ~/bitwise/bitwise-deploy/deploy/aws

# Real-time logs for all services
docker compose logs -f

# Last 100 lines of backend logs
docker compose logs --tail=100 backend

# Logs since last hour
docker compose logs --since 1h frontend
```

### Restart Services

```bash
cd ~/bitwise/bitwise-deploy/deploy/aws

# Restart all services
docker compose restart

# Restart specific service
docker compose restart backend
```

### Stop Services

```bash
cd ~/bitwise/bitwise-deploy/deploy/aws

# Stop all services
docker compose down

# Stop and remove volumes (careful!)
docker compose down -v
```

### Cleanup

```bash
# Remove unused images
docker image prune -f

# Remove all unused resources
docker system prune -af
```

### SSL Certificate Renewal

Traefik automatically renews Let's Encrypt certificates. To verify:

```bash
cd ~/bitwise/bitwise-deploy/deploy/aws
ls -la letsencrypt/acme.json
```

## Security Best Practices

1. **Environment Variables**: Never commit `.env` files to Git
2. **SSH Keys**: Use strong SSH keys and restrict access by IP when possible
3. **Secrets Rotation**: Regularly rotate JWT secrets, API keys, and database passwords
4. **Updates**: Keep Docker, Docker Compose, and the OS updated
5. **Monitoring**: Set up CloudWatch or equivalent for monitoring
6. **Backups**: Regularly backup your database and environment files

## Additional Resources

- [AWS Deployment Guide](aws/README.md) - AWS-specific configuration
- [Secrets Management](aws/SECRETS_MANAGEMENT.md) - Managing sensitive data
- [Troubleshooting Guide](aws/TROUBLESHOOTING.md) - Common issues and solutions

## Support

For deployment issues:
1. Check the [Troubleshooting Guide](aws/TROUBLESHOOTING.md)
2. Review application logs
3. Verify GitHub Actions workflow runs
4. Check EC2 instance health and resource usage
