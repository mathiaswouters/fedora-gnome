# Fedora Gnome

## Inspiration
[typecraft - crucible](https://github.com/typecraft-dev/crucible)

## !!! ADD PART TO INSTALL GRAPHIC (NVIDIA) DRIVERS !!!

## Gnome Extensions
- Just Perfection (@just-perfection)
- Search Light (@icedman.github.com) OR Switcher (@dlandau)
- Space bar (@luchrioh)
- Tactile (@lundal.io)
- TopHat (@fflewddur.github.io)
- Blur my shell (@aunetx)

## Packages

See [packages.conf](config/packages.conf) file

## How to load Gnome Settings file:

`dconf load /org/gnome/shell/extensions/ < config/gnome-settings.dconf`

## Script Guide

`sudo dnf install git -y`
`git clone https://github.com/mathiaswouters/fedora-gnome`
`cd fedora-gnome`
`chmod +x run.sh`
`chmod +x scripts/*.sh`
`./run.sh`
