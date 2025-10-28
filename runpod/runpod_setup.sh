#!/bin/bash

KEY_FILE="$HOME/.env_vars"
if [[ ! -f "$KEY_FILE" ]]; then
  echo "Key file not found at $KEY_FILE"
  exit 1
fi
source "$KEY_FILE"

# 1) Setup linux dependencies
su -c 'apt-get update && apt-get install -y sudo'
sudo apt-get install -y less nano htop ncdu nvtop lsof rsync btop jq

# 2) Setup virtual environment
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv python install 3.11
uv venv
source .venv/bin/activate
python -m ipykernel install --user --name=venv # so it shows up in jupyter notebooks within vscode

# 3) Setup dotfiles and ZSH
mkdir git && cd git
git clone https://github.com/constanzafierro/dotfiles.git
cd dotfiles
./install.sh --zsh --tmux
chsh -s /usr/bin/zsh
./deploy.sh
cd

uv pip install wandb huggingface-hub
wandb login "$WANDB_API_KEY"
uv pip install git+https://github.com/safety-research/safety-tooling.git@main#egg=safetytooling
export UV_TORCH_BACKEND='cu128'
uv pip install vllm --torch-backend=$UV_TORCH_BACKEND
uv cache clean
#wget https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.4.11/flash_attn-2.8.3+cu128torch2.8-cp311-cp311-linux_x86_64.whl
#uv pip install ./flash_attn-2.8.3+cu128torch2.8-cp311-cp311-linux_x86_64.whl
#rm -f flash_attn*.whl
#uv pip install --no-build-isolation 'axolotl[deepspeed]'
#uv pip install --upgrade huggingface_hub
#uv pip install --upgrade transformers
uv pip install accelerate
uv pip install --upgrade datasets
#uv pip uninstall numpy
uv pip install numpy==2.2

cat ~/.env_vars | tee -a /root/git/dotfiles/config/zshrc.sh
echo 'bindkey \^U backward-kill-line' >> ~/.zshrc
git config --global core.excludesfile /workspace/.gitignore_global
