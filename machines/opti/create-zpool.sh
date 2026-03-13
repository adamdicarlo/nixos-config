#!/usr/bin/env bash
set +ex

# 8TB, 8TB, 10TB -- need -f
zpool create \
  -f \
  -o ashift=12 \
  -o autotrim=on \
  -O compression=lz4 \
  -O recordsize=1M \
  -O acltype=posixacl \
  -O atime=off \
  -O canmount=on \
  -O mountpoint=legacy \
  -O xattr=sa \
  slab \
  raidz1 \
  ata-WDC_WD80EFAX-68LHPN0_7SGWRANC \
  ata-WDC_WD80EFZX-68UW8N0_R6GZ24NY \
  ata-WDC_WD100EZAZ-11TDBA0_4DGY905Z

zfs set reservation=1T slab
