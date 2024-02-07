{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              start = "1M";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true;
                };
                passwordFile = "/run/media/nixos/sneakernet/boot.txt";
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        name = "pool";
        type = "lvm_vg";
        lvs = {
          swap = {
            name = "swap";
            size = "17226M";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          root = {
            name = "root";
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" ];
              postMountHook = ''
                # Leave some unallocated space in the VG for e2scrub.
                #
                # Unfortunately, we can't use arithmetic for LV size; it would
                # be nice to write something like "100%FREE - 1GB". Decimals
                # (e.g., "99.8%FREE") are not supported, either.
                lvreduce /dev/pool/root --size -1G --resizefs --yes
              '';
            };
          };
        };
      };
    };
  };
}
