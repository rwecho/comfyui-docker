#!/bin/bash

set -e

NODES_FILE="/extra_nodes.txt"
TARGET_DIR="/root/ComfyUI/custom_nodes"

if [ -f "$NODES_FILE" ]; then
    echo "----------------------------------------------------------------"
    echo "Build-time: Installing custom nodes from $NODES_FILE..."
    echo "----------------------------------------------------------------"
    
    # Read file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        # Trim whitespace
        line=$(echo "$line" | xargs)
        
        # Skip empty lines and comments
        if [[ -z "$line" || "$line" == \#* ]]; then
            continue
        fi
        
        repo_name=$(basename "$line" .git)
        repo_dir="$TARGET_DIR/$repo_name"
        
        if [ ! -d "$repo_dir" ]; then
            echo "Cloning $repo_name..."
            git clone --depth=1 "$line" "$repo_dir"
            
            if [ -f "$repo_dir/requirements.txt" ]; then
                echo "Installing requirements for $repo_name..."
                pip install --no-cache-dir -r "$repo_dir/requirements.txt"
            fi
        else
            echo "$repo_name already exists."
        fi
    done < "$NODES_FILE"
fi
