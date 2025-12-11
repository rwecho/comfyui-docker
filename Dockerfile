ARG PYTORCH_VERSION=2.9.1-cuda13.0-cudnn9-devel

FROM pytorch/pytorch:${PYTORCH_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

# Installs Git, because ComfyUI and the ComfyUI Manager are installed by cloning their respective Git repositories
# Added ffmpeg and aria2 as they are commonly used in ComfyUI workflows
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    git \
    sudo \
    libgl1-mesa-glx \
    vim \
    libglib2.0-0 \
    ffmpeg \
    aria2 \
    && rm -rf /var/lib/apt/lists/*

# Clones the ComfyUI repository
RUN git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git /root/ComfyUI \
    && mkdir -p /root/ComfyUI/custom_nodes \
    && git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Manager.git /root/ComfyUI/custom_nodes/ComfyUI-Manager


# Install dependencies
# Use cache for pip to speed up rebuilds
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r /root/ComfyUI/requirements.txt && \
    pip install -r /root/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt

# Copy entrypoint script and nodes list
COPY extra_nodes.txt /extra_nodes.txt
COPY install_nodes.sh /install_nodes.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /install_nodes.sh /entrypoint.sh && \
    /install_nodes.sh

WORKDIR /root/ComfyUI

EXPOSE 8188
ENV CLI_ARGS=""
CMD ["/entrypoint.sh"]