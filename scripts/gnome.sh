#!/bin/bash

# Exit on any error
set -e

### gnome extensions ###

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Make sure that pipx is installed
if ! command -v pipx &>/dev/null; then
  echo "Installing pipx..."
  sudo dnf install -y pipx
  pipx ensurepath
fi

# Install gnome-extensions-cli only if not already installed
if ! command -v gext &> /dev/null; then
  pipx install gnome-extensions-cli --system-site-packages
fi

EXTENSIONS=(
  "blur-my-shell@aunetx"
  "forge@jmmaranan.com"
  "just-perfection-desktop@just-perfection"
  "search-light@icedman.github.com"
  "space-bar@luchrioh"
  "tactile@lundal.io"
  "tophat@fflewddur.github.io"
)

for ext in "${EXTENSIONS[@]}"; do
  if ! gext list | grep "$ext" &> /dev/null; then
    echo "Installing extension: $ext"
    gext install "$ext"
  else
    echo "Extension already installed: $ext"
  fi
done

# Now load settings from dconf file
dconf load /org/gnome/shell/extensions/ < "$SCRIPT_DIR/config/gnome-settings.dconf"


### gnome hotkeys ###

gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 6

gsettings set org.gnome.shell.keybindings switch-to-application-1 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-7 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-8 "[]"
gsettings set org.gnome.shell.keybindings switch-to-application-9 "[]"

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"

gsettings set org.gnome.desktop.wm.keybindings close "['<Super>w']"


### gnome settings ###

gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
