#!/bin/bash

set -e

REPO_URL="https://github.com/mathiaswouters/dotfiles"
REPO_NAME="dotfiles"

echo "Cloning and setting up dotfiles..."

DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles repo..."
  git clone $REPO_URL.git "$DOTFILES_DIR"
fi

sudo rm $HOME/.zshrc

cd "$DOTFILES_DIR"

stow zsh alacritty ghostty nvim tmux ohmyposh wallpapers
