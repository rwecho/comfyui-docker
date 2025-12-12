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
        else
            echo "$repo_name already exists."
        fi
    done < "$NODES_FILE"

    # Merge and install requirements
    echo "----------------------------------------------------------------"
    echo "Merging and installing dependencies..."
    echo "----------------------------------------------------------------"
    
    TEMP_REQ="/tmp/combined_requirements.txt"
    CLEAN_REQ="/tmp/clean_requirements.txt"
    
    # Find all requirements.txt files in custom_nodes subdirectories
    # Use awk 1 to ensure files ending without newline don't merge with next file's first line
    find "$TARGET_DIR" -mindepth 2 -maxdepth 2 -name "requirements.txt" -exec awk 1 {} + > "$TEMP_REQ"
    
    if [ -s "$TEMP_REQ" ]; then
        # Process requirements:
        # 1. Remove comments
        # 2. Remove version constraints (>=, ==, etc.) to force latest
        # 3. Remove empty lines
        # 4. Sort and unique
        sed 's/#.*//g' "$TEMP_REQ" | \
        sed -E 's/([<>=!~;]).*//g' | \
        tr -d '\r' | \
        awk '{$1=$1};1' | \
        sort -u | \
        grep -v "^$" > "$CLEAN_REQ"
        
        echo "Installing combined dependencies (using latest versions):"
        cat "$CLEAN_REQ"
        
        pip install --no-cache-dir --upgrade -r "$CLEAN_REQ"
        
        rm "$TEMP_REQ" "$CLEAN_REQ"
    else
        echo "No requirements found to install."
    fi
fi
