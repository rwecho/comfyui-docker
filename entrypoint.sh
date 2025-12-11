#!/bin/bash

set -e

echo "Starting ComfyUI..."
cd /root/ComfyUI

# Run ComfyUI
# --listen 0.0.0.0 allows access from outside the container
exec python main.py --listen 0.0.0.0 --port 8188 ${CLI_ARGS}
