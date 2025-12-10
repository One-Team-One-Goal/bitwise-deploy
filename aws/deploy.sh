#!/bin/bash

set -e

echo "🚀 Starting deployment process..."

# Get the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📂 Script directory: $SCRIPT_DIR"

# Calculate the root directory (assuming script is in bitwise-deploy/aws)
# We need to go up 2 levels: aws -> bitwise-deploy -> bitwise (root)
ROOT_DIR="$SCRIPT_DIR/../.."

cd "$ROOT_DIR"
echo "📂 Working in root: $(pwd)"

echo "⬇️  Pulling latest code from git..."

# Function to pull a repo
pull_repo() {
    local dir=$1
    if [ -d "$dir" ]; then
        echo "   Updating $dir..."
        cd "$dir"
        git pull origin main
        cd - > /dev/null
    else
        echo "⚠️  Warning: Directory $dir not found. Skipping git pull."
    fi
}

pull_repo "bitwise-deploy"
pull_repo "bitwise-server"
pull_repo "bitwise-ui"

cd bitwise-deploy/aws

# Ensure acme.json exists and has correct permissions
if [ ! -f "./letsencrypt/acme.json" ]; then
    mkdir -p ./letsencrypt
    touch ./letsencrypt/acme.json
fi
sudo chmod 600 ./letsencrypt/acme.json

echo "🧹 Cleaning up old Docker resources..."
docker image prune -af
docker builder prune -f

echo "🔄 Rebuilding and restarting containers (with retry logic)..."
# Retry up to 3 times in case of network issues
MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "   Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES..."
    
    if docker compose version >/dev/null 2>&1; then
        if docker compose up -d --build --remove-orphans; then
            echo "✅ Deployment successful!"
            break
        fi
    else
        if docker-compose up -d --build --remove-orphans; then
            echo "✅ Deployment successful!"
            break
        fi
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
        echo "⚠️  Build failed, retrying in 10 seconds..."
        sleep 10
    else
        echo "❌ Deployment failed after $MAX_RETRIES attempts"
        exit 1
    fi
done

echo "🧹 Cleaning up unused docker images..."
docker image prune -f

echo "✅ Deployment complete!"
