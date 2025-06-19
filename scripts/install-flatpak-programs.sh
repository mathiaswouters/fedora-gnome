#!/bin/bash

set -e

FLATPAK_APPS=(
  com.bitwarden.desktop
  com.spotify.Client
  com.google.Chrome
)

for app in "${FLATPAK_APPS[@]}"; do
  if ! flatpak list | grep -q "${app}"; then
    echo "Installing $app via Flatpak..."
    flatpak install -y flathub "$app"
  else
    echo "$app already installed"
  fi
done
