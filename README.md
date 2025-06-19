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

1) `sudo dnf install git -y`

2) `git clone https://github.com/mathiaswouters/fedora-gnome`

3) `cd fedora-gnome`

4) `chmod +x run.sh`

5) `chmod +x scripts/*.sh`

6) `./run.sh`
