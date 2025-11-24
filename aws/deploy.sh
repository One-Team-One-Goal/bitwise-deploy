#!/bin/bash

set -e

echo "🚀 Starting deployment process..."

# Navigate to the script's directory
cd "$(dirname "$0")"

echo "📂 Current directory: $(pwd)"

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

# The script is at ~/bitwise/bitwise-deploy/aws/deploy.sh
# We want to go to ~/bitwise
ROOT_DIR="$(dirname "$0")/../.."

cd "$ROOT_DIR"
echo "📂 Working in root: $(pwd)"

pull_repo "bitwise-deploy"
pull_repo "bitwise-server"
pull_repo "bitwise-ui"

cd bitwise-deploy/aws

echo "🔄 Rebuilding and restarting containers..."
if docker compose version >/dev/null 2>&1; then
    docker compose up -d --build --remove-orphans
else
    docker-compose up -d --build --remove-orphans
fi

echo "🧹 Pruning unused docker images..."
docker image prune -f

echo "✅ Deployment complete!"
