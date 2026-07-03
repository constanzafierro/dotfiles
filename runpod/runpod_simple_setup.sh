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
uv pip install ipykernel
python -m ipykernel install --user --name=venv # so it shows up in jupyter notebooks within vscode
# Inject env into the venv kernelspec so Jupyter kernels see it
# regardless of how the Jupyter server was started
python - <<'EOF'
import json, os
p = os.path.expanduser("~/.local/share/jupyter/kernels/venv/kernel.json")
d = json.load(open(p))
d["env"] = {
    "PATH": os.path.expanduser("~/.venv/bin") + ":${PATH}",
    "VIRTUAL_ENV": os.path.expanduser("~/.venv"),
    "HF_HOME": os.environ["HF_HOME"],
    "HF_HUB_CACHE": os.environ["HF_HUB_CACHE"],
}
json.dump(d, open(p, "w"), indent=1)
EOF

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

cat ~/.env_vars | tee -a /root/git/dotfiles/config/zshrc.sh
echo 'bindkey \^U backward-kill-line' >> ~/.zshrc
git config --global core.excludesfile /workspace/.gitignore_global

# RunPod proxy SSH always starts bash; hand off to zsh
if [ -t 1 ] && [ -x /usr/bin/zsh ] && [ -z "$ZSH_VERSION" ]; then cd ~ && exec /usr/bin/zsh -l; fi
