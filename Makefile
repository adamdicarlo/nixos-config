# Get directory of this file. https://stackoverflow.com/a/23324703
NIXOS_CONFIG_PATH:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

default:
	sudo NIXOS_CONFIG_PATH=$(NIXOS_CONFIG_PATH) nixos-rebuild switch --impure

switch:
	sudo NIXOS_CONFIG_PATH=$(NIXOS_CONFIG_PATH) nixos-rebuild switch --impure
