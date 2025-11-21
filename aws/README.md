# Bitwise Deployment Guide (AWS/EC2)

This guide explains how to deploy the Bitwise application using the configuration in this directory.

## 1. Prerequisites

- **Docker & Docker Compose** installed on your EC2 instance.
- **Git** installed.
- **SSH Access** to your EC2 instance.

## 2. Deployment Steps

### Step 1: Clone the Repository

SSH into your EC2 instance and clone the main repository.

```bash
git clone <your-repo-url> bitwise
cd bitwise
```

### Step 2: Navigate to Deployment Directory

The deployment configuration is located in `deploy/aws`.

```bash
cd deploy/aws
```

### Step 3: Configure Environment Variables

Create a `.env` file in the `deploy/aws` directory.

```bash
nano .env
```

Paste your environment variables:

```env
NODE_ENV=production
DATABASE_URL="postgresql://user:password@host:port/db"
DIRECT_URL="postgresql://user:password@host:port/db"
JWT_SECRET="your-secret-key"
FRONTEND_URL="http://your-ec2-public-ip"
```

### Step 4: Start the Application

Run Docker Compose from this directory. It is configured to look for the source code in the parent directories (`../../bitwise-server` and `../../bitwise-ui`).

```bash
docker-compose up --build -d
```

### Step 5: Verify

- **Backend**: Running on port 3000.
- **Frontend**: Running on port 80.

Visit `http://your-ec2-public-ip` in your browser.

## Troubleshooting

- **Logs**: Check logs with `docker-compose logs -f`.
- **Rebuild**: If you pull new code, run `docker-compose up --build -d` again.
