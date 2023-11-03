#!/usr/bin/env bash
if [[ -z "$1" ]] || [[ ! -d "./machines/$1" ]]; then
	echo "Invalid machine name: '$1'"
	exit 1
fi
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
sudo mv /etc/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix.old
sudo ln -s $PWD/machines/$1/default.nix /etc/nixos/configuration.nix
sudo ln -s $PWD/machines/$1/hardware.nix /etc/nixos/hardware.nix
