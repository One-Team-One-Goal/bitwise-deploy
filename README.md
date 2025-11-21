# Bitwise Deployment

This folder contains the deployment configuration for the Bitwise application.

## Prerequisites

- An EC2 instance (Ubuntu recommended).
- Docker and Docker Compose installed on the instance.
- SSH access to the instance.

## Directory Structure

Since the project is not a monorepo, we assume you will clone the repositories as siblings on your server. Your directory structure on the server should look like this:

```
/home/ubuntu/
├── bitwise-server/       # Cloned from backend repo
├── bitwise-ui/           # Cloned from frontend repo
└── deploy/               # This folder (or cloned from deploy repo)
    ├── docker-compose.yml
    ├── .env
    └── README.md
```

## Deployment Steps

1.  **SSH into your EC2 Instance**
    Use your key file and the Public IPv4 address of your instance.
    ```bash
    ssh -i "path/to/your-key.pem" ubuntu@<your-ec2-public-ip>
    ```

2.  **Clone the Repositories**
    ```bash
    cd ~
    git clone <backend-repo-url> bitwise-server
    git clone <frontend-repo-url> bitwise-ui
    # If this deploy folder is in a repo, clone it too, or just copy the files.
    mkdir deploy
    ```
    *If you are just copying files, use SCP or create them manually.*

3.  **Setup Environment Variables**
    Create a `.env` file in the `deploy` directory.
    ```bash
    cd ~/deploy
    nano .env
    ```
    Add your variables:
    ```env
    NODE_ENV=production
    DATABASE_URL="postgresql://..."
    DIRECT_URL="postgresql://..."
    JWT_SECRET="your-secret"
    FRONTEND_URL="http://<your-ec2-public-ip>"
    ```

4.  **Run the Application**
    From the `deploy` directory:
    ```bash
    docker-compose up --build -d
    ```

5.  **Verify**
    -   Frontend: `http://<your-ec2-public-ip>`
    -   Backend: `http://<your-ec2-public-ip>:3000`

## Updating

To update the application:
1.  Go to the respective folder (`cd ../bitwise-server` or `cd ../bitwise-ui`).
2.  Pull changes: `git pull`.
3.  Go back to deploy: `cd ../deploy`.
4.  Rebuild: `docker-compose up --build -d`.
