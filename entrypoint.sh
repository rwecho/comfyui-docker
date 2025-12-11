#!/bin/bash

set -e

cd /root/ComfyUI

# Function to install custom nodes
install_node() {
    local repo_url=$1
    local repo_name=$(basename "$repo_url" .git)
    local target_dir="custom_nodes/$repo_name"

    if [ ! -d "$target_dir" ]; then
        echo "Installing $repo_name..."
        git clone --depth=1 "$repo_url" "$target_dir"
        if [ -f "$target_dir/requirements.txt" ]; then
            echo "Installing requirements for $repo_name..."
            pip install --no-cache-dir -r "$target_dir/requirements.txt"
        fi
    else
        echo "$repo_name already installed."
    fi
}

# Check and restore ComfyUI-Manager if missing (e.g. if volume mounted)
if [ ! -d "custom_nodes/ComfyUI-Manager" ]; then
    echo "ComfyUI-Manager not found. Installing..."
    install_node "https://github.com/ltdrdata/ComfyUI-Manager.git"
fi

# Install extra nodes from environment variable (comma separated)
if [ -n "$EXTRA_NODES" ]; then
    echo "Installing extra nodes from environment..."
    IFS=',' read -ra ADDR <<< "$EXTRA_NODES"
    for repo in "${ADDR[@]}"; do
        install_node "$repo"
    done
fi

echo "----------------------------------------------------------------"
echo "Starting ComfyUI..."
echo "----------------------------------------------------------------"

# Run ComfyUI
# --listen 0.0.0.0 allows access from outside the container
exec python main.py --listen 0.0.0.0 --port 8188 ${CLI_ARGS}
