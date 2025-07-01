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

# 3) Setup dotfiles and ZSH
mkdir git && cd git
git clone https://github.com/constanzafierro/dotfiles.git
cd dotfiles
./install.sh --zsh --tmux
chsh -s /usr/bin/zsh
./deploy.sh
cd ..

pip install wandb huggingface-hub
wandb login "$WANDB_API_KEY"

# 4) Setup github
chmod +x git/dotfiles/runpod/setup_github.sh
./git/dotfiles/runpod/setup_github.sh "cfierromella@gmail.com" "constanzafierro"
