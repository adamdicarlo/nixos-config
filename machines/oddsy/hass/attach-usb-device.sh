#!/usr/bin/env bash
virsh --connect qemu:///system \
  attach-device \
  --persistent \
  --domain hass \
  --file ./aeotec-usb-device.xml
