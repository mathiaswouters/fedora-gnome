#!/bin/bash

set -e

####################
### Define Paths ###
####################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
BLOAT_FILE="$CONFIG_DIR/bloat-fedora-gnome"
PACKAGE_CONF="$CONFIG_DIR/packages.conf"
GNOME_SETTINGS="$CONFIG_DIR/gnome-settings.dconf"

##################
### Print Logo ###
##################
source "$SCRIPT_DIR/scripts/logo.sh"

clear
print_logo
echo

#############################
### Validate Linux Distro ###
#############################
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [[ "$ID" != "fedora" ]]; then
    echo "This script is intended for Fedora systems only. Detected: $ID"
    exit 1
  fi
else
  echo "Cannot detect operating system. /etc/os-release not found."
  exit 1
fi

# ############################
# ### Validate Environment ###
# ############################
# if [[ "${XDG_CURRENT_DESKTOP:-}" != *"GNOME"* ]]; then
#   echo "This script is intended for GNOME environments only. Detected: ${XDG_CURRENT_DESKTOP:-<not set>}"
#   exit 1
# fi

###########################
### Source Package List ###
###########################
if [ ! -f "$PACKAGE_CONF" ]; then
  echo "Error: packages.conf not found at $PACKAGE_CONF"
  exit 1
fi

source "$PACKAGE_CONF"

#######################
### Keep Sudo Alive ###
#######################
if sudo -v; then
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
else
  echo "Failed to obtain sudo privileges."
  exit 1
fi

##########################
### Setup New Hostname ###
##########################
read -rp "Enter the desired hostname: " NEW_HOSTNAME

if [[ -n "$NEW_HOSTNAME" ]]; then
  echo "Setting hostname to '$NEW_HOSTNAME'"
  sudo hostnamectl set-hostname "$NEW_HOSTNAME"
else
  echo "No hostname provided. Skipping..."
fi

#####################
### Update System ###
#####################
echo "Updating system..."
sudo dnf update -y

########################
### Install GNOME DE ###
########################
echo "Installing GNOME Desktop Environment..."
sudo dnf group install workstation-product-environment -y

#############################
### Remove Bloat Packages ###
#############################
echo "Removing bloat packages"
BLOAT_PACKAGES=$(grep -vE '^\s*#|^\s*$' "$BLOAT_FILE")
if [[ -n "$BLOAT_PACKAGES" ]]; then
  for pkg in $BLOAT_PACKAGES; do
    if rpm -q "$pkg" &>/dev/null; then
      echo "Removing $pkg..."
      sudo dnf remove -y "$pkg"
    else
      echo "Skipping $pkg (not installed)"
    fi
  done
else
  echo "Bloat package list not found at $BLOAT_FILE"
fi

###############################################
### Setting up Repositories & Prerequisites ###
###############################################
echo "Setting up repositories & installing prerequisites..."

sudo dnf copr enable pgdev/ghostty -y
sudo dnf copr enable atim/lazygit -y
sudo dnf copr enable lihaohong/yazi -y

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
dnf check-update || true

#########################
### Enable RPM Fusion ###
#########################
echo "Enabling RPM Fusion..."
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

#################################
### Install Flatpak & Flathub ###
#################################
echo "Installing Flatpak and Flathub..."

if ! command -v flatpak &>/dev/null; then
  sudo dnf install -y flatpak
else
  echo "Flatpak is already installed"
fi

# Add Flathub repository if not already present
if ! flatpak remote-list | grep -q flathub; then
  echo "Adding Flathub remote..."
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
else
  echo "Flathub is already configured"
fi

##############################
### Package install helper ###
##############################
install_packages() {
  local pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    if ! rpm -q "$pkg" &>/dev/null; then
      echo "Installing $pkg..."
      sudo dnf install -y "$pkg"
    else
      echo "$pkg already installed"
    fi
  done
}

########################
### Install Packages ###
########################
echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"

echo "Installing development tools..."
install_packages "${DEV_TOOLS[@]}"

echo "Installing system maintenance tools..."
install_packages "${MAINTENANCE[@]}"

echo "Installing gnome packages..."
install_packages "${DESKTOP[@]}"

echo "Installing media packages..."
install_packages "${MEDIA[@]}"

echo "Installing other packages..."
install_packages "${OTHERS[@]}"

# echo "Installing fonts..."
# install_packages "${FONTS[@]}"

#######################
### Enable services ###
#######################
echo "Enabling services..."
for service in "${SERVICES[@]}"; do
  sudo systemctl enable "$service" || echo "Warning: Failed to enable $service"
done

#######################
### Install NordVPN ###
#######################
echo "Installing NordVPN..."
sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh) -p nordvpn-gui
sudo groupadd nordvpn
sudo usermod -aG nordvpn $USER

###########################
### GNOME Configuration ###
###########################
echo "Configuring GNOME..."
source "$SCRIPT_DIR/scripts/gnome.sh"

############################
### Install Flatpak Apps ###
############################
echo "Installing Flatpak applications..."
source "$SCRIPT_DIR/scripts/install-flatpak-programs.sh"

##########################
### Install Oh My Posh ###
##########################
echo "Installing Oh My Posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s

#####################
### Install Zinit ###
#####################
echo "Installing Zinit..."
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

######################
### Setup dotfiles ###
######################
echo "Setting up dotfiles..."
source "$SCRIPT_DIR/scripts/dotfiles-setup.sh"

### Setup wallpaper ###
echo "Setting wallpaper..."
gsettings set org.gnome.desktop.background picture-uri-dark "file://~/.config/wallpapers/wallpaper.png"
gsettings set org.gnome.desktop.background picture-options 'zoom'

echo
echo "Setup complete! Reboot recommended"
