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

cat >> ~/.zshrc << 'EOF'

# >>> conda initialize >>>
__conda_setup="$('/root/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/root/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/root/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/root/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Optional: auto-activate your preferred env
conda activate py3.11
# <<< conda initialize <<<

EOF
