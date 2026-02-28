#!/bin/bash
set -e

source /venv/main/bin/activate

WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR=${WORKSPACE}/ComfyUI

echo "=== Vast.ai ComfyUI provisioning ==="

# ---------------------------------------------
# CONFIG — NODES
# ---------------------------------------------
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/ClownsharkBatwing/RES4LYF"
    "https://github.com/chrisgoringe/cg-use-everywhere"
    "https://github.com/Smirnov75/ComfyUI-mxToolkit"
    "https://github.com/TheLustriVA/ComfyUI-Image-Size-Tools"
    "https://github.com/ZhiHui6/zhihui_nodes_comfyui"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/crystian/ComfyUI-Crystools"
    "https://github.com/jnxmx/ComfyUI_HuggingFace_Downloader"
    "https://github.com/plugcrypt/CRT-Nodes"
    "https://github.com/EllangoK/ComfyUI-post-processing-nodes"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
)

# ---------------------------------------------
# 1. Clone ComfyUI
# ---------------------------------------------
if [[ ! -d "${COMFYUI_DIR}" ]]; then
    echo "Cloning ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "${COMFYUI_DIR}"
fi

cd "${COMFYUI_DIR}"

# ---------------------------------------------
# 2. Install base requirements
# ---------------------------------------------
if [[ -f requirements.txt ]]; then
    pip install --no-cache-dir -r requirements.txt
fi

# ---------------------------------------------
# 3. Custom nodes
# ---------------------------------------------
mkdir -p custom_nodes

for repo in "${NODES[@]}"; do
    dir="${repo##*/}"
    path="custom_nodes/${dir}"

    if [[ -d "$path" ]]; then
        echo "Updating node: $dir"
        (cd "$path" && git pull --ff-only 2>/dev/null || { git fetch && git reset --hard origin/main; })
    else
        echo "Cloning node: $dir"
        git clone "$repo" "$path" --recursive || echo " [!] Clone failed: $repo"
    fi

    [[ -f "${path}/requirements.txt" ]] && pip install --no-cache-dir -r "${path}/requirements.txt" \
        || echo " [!] pip requirements failed for $dir"
done

# ---------------------------------------------
# 4. Launch
# ---------------------------------------------
echo "=== Starting ComfyUI ==="
python main.py --listen 0.0.0.0 --port 8188
