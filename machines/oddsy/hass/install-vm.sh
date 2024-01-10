#!/usr/bin/env bash

VIRSH="virsh --connect qemu:///system"
# https://myme.no/posts/2021-11-25-nixos-home-assistant.html#connect-to-console-using-remote-viewer
if ! $VIRSH net-info bridged-network; then
  echo "Creating bridged-network"
  $VIRSH net-define bridged-network.xml
  $VIRSH net-autostart bridged-network
fi

echo "After machine is created, run:"
echo
echo "  $VIRSH autostart hass"

virt-install --name hass \
  --boot uefi \
  --connect qemu:///system \
  --cpu host \
  --description "Home Assistant OS" \
  --disk ./haos_ova-11.2.qcow2,bus=sata \
  --graphics "spice,listen=0.0.0.0" \
  --import \
  --memory 4096 \
  --network network=bridged-network \
  --os-variant=generic \
  --vcpus=2 \
  --hostdev 001.002
