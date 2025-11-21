# Bitwise Deployment (AWS EC2)

This directory contains the configuration to deploy the Bitwise application on AWS EC2 using Docker Compose.

## 🚨 Critical Fix for "KeyError: 'ContainerConfig'"

If you see `KeyError: 'ContainerConfig'` when running `docker-compose`, it means your installed version of `docker-compose` (likely v1.29.x) is too old and incompatible with the Docker Engine on your EC2 instance.

**Solution: Use the new Docker Compose V2 plugin.**

1.  **Check if you have the new command:**
    Try running:
    ```bash
    docker compose version
    ```
    *(Note the space between `docker` and `compose`, no hyphen)*.

2.  **If it works (shows v2.x.x):**
    Use `docker compose` instead of `docker-compose` for all commands.
    ```bash
    docker compose up --build -d
    ```

3.  **If it says "command not found" or you need to install it:**
    Run these commands to install the latest Docker Compose plugin:
    ```bash
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
    ```
    Then verify: `docker compose version`

---

## 🚀 Deployment Steps

### 1. Prepare the Server
Ensure your project structure on the server looks like this:
```
~/bitwise/
├── bitwise-server/   (Backend code + .env)
├── bitwise-ui/       (Frontend code + .env)
└── deploy/
    └── aws/
        ├── docker-compose.yml
        └── README.md
```

### 2. Environment Variables
Since you mentioned you have envs in the repos:
- Ensure `bitwise-server/.env` exists and has `DATABASE_URL`, `JWT_SECRET`, etc.
- Ensure `bitwise-ui/.env` exists (if needed for build).

### 3. Run the Application
Navigate to this directory and run:

```bash
cd ~/bitwise/deploy/aws

# Build and start containers (using V2 command)
docker compose up --build -d
```

### 4. Verify
- **Backend Logs:** `docker compose logs -f backend`
- **Frontend Logs:** `docker compose logs -f frontend`

## 🛠 Troubleshooting

- **"permission denied"**: Add `sudo` before docker commands, or add your user to the docker group: `sudo usermod -aG docker $USER` (then logout and login).
- **Frontend not connecting**: Ensure `FRONTEND_URL` in backend .env matches your EC2 IP/Domain, and your Frontend code points to the correct Backend URL.
