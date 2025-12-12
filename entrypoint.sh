#!/bin/bash

set -e

cd /root/ComfyUI

echo "----------------------------------------------------------------"
echo "Starting ComfyUI..."
echo "----------------------------------------------------------------"

# Run ComfyUI
# --listen 0.0.0.0 allows access from outside the container
exec python main.py --listen 0.0.0.0 --port 8188 ${CLI_ARGS}
