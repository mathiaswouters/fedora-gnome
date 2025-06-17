#!/bin/bash

# Print Morpheus & Logo
source ./morpheus.sh
source ./logo.sh

clear
print_morpheus
echo
print_logo

# Exit on any error
set -e

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../../config"
WALLPAPER_PATH="$CONFIG_DIR/wallpaper.png"
BLOAT_FILE="$CONFIG_DIR/bloat-fedora-gnome"
COMMON_PACKAGES_FILE="$CONFIG_DIR/packages-common"
FEDORA_PACKAGES_FILE="$CONFIG_DIR/packages-fedora"
FEDORA_FLATPAK_FILE="$CONFIG_DIR/packages-fedora-flatpak"

# Check if the current desktop environment is GNOME
if [[ "${XDG_CURRENT_DESKTOP:-}" != *"GNOME"* ]]; then
    echo "This script is intended for GNOME environments only. Detected: ${XDG_CURRENT_DESKTOP:-<not set>}"
    exit 1
fi

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source packages.conf

# Prompt for sudo password upfront and keep-alive in background
if sudo -v; then
    # Keep sudo session alive
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
else
    echo "Failed to obtain sudo privileges."
    exit 1
fi

# Prompt for new hostname
read -rp "Enter the desired hostname: " NEW_HOSTNAME

if [[ -n "$NEW_HOSTNAME" ]]; then
    echo "Setting hostname to '$NEW_HOSTNAME'"
    sudo hostnamectl set-hostname "$NEW_HOSTNAME"
else
    echo "No hostname provided. Skipping."
fi

# Update system
echo "Updating system..."
sudo dnf update -y

# Remove bloat packages
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
fi

# Prerequisits:
echo "Installing prerequisits..."

sudo dnf copr enable pgdev/ghostty -y

sudo dnf copr enable atim/lazygit -y

sudo dnf copr enable lihaohong/yazi -y

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf check-update

# Enable RPM Fusion
echo "Enabling RPM Fusion..."
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                 https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install Flatpak and flathub
echo "Installing Flatpak and Flathub..."

if ! command -v flatpak &> /dev/null; then
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

# Install packages by category
echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"
  
echo "Installing development tools..."
install_packages "${DEV_TOOLS[@]}"
  
echo "Installing system maintenance tools..."
install_packages "${MAINTENANCE[@]}"

echo "Installing desktop environment..."
install_packages "${DESKTOP[@]}"
  
echo "Installing desktop environment..."
install_packages "${OFFICE[@]}"
  
echo "Installing media packages..."
install_packages "${MEDIA[@]}"
  
echo "Installing fonts..."
install_packages "${FONTS[@]}"

# Enable services
echo "Configuring services..."
for service in "${SERVICES[@]}"; do
  if ! systemctl is-enabled "$service" &> /dev/null; then
    echo "Enabling $service..."
    sudo systemctl enable "$service"
  else
    echo "$service is already enabled"
  fi
done
  
# Install gnome things
echo "Installing Gnome extensions..."
. scripts/gnome-extensions.sh
echo "Setting Gnome hotkeys..."
. scripts/gnome-hotkeys.sh
echo "Configuring Gnome..."
. scripts/gnome-settings.sh
 
# Install Flatpak programs
echo "Installing flatpak programs"
. scripts/install-flatpak-programs.sh

# Install Oh My Posh
echo "Installing Oh My Posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s

# Install Zinit
echo "Installing Zinit..."
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

echo "Setup complete! You may want to reboot your system."