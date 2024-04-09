{pkgs, ...}: {
  imports = [
    ../common.nix
    ../laptop.nix
    ./hardware.nix
  ];

  hardware.system76.enableAll = true;
  services.system76-scheduler.enable = true;

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 4;
  };
  boot.kernelParams = [
    "blacklist=nvidia"
  ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-89774725-33d7-4569-98ca-969947979248".device = "/dev/disk/by-uuid/89774725-33d7-4569-98ca-969947979248";

  boot.blacklistedKernelModules = ["nvidia"];
  networking.hostName = "tiv";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [];

  programs._1password = {
    enable = true;
  };
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["adam"];
  };
  security.polkit = {
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id === "com.1password.1Password.authorizeSshAgent"
          && subject.isInGroup("wheel")
          && action.message
          && action.message.includes("1Password is trying to allow “kitty” to use the key “GitHub” for SSH")
        ) {
          return polkit.Result.AUTH_SELF_KEEP
        }
      })
    '';
  };

  programs.sway = {
    enable = true;
    extraOptions = [
      "--unsupported-gpu"
    ];
    # Render via the iGPU (intel device) only! (Is --unsupported-gpu actually necessary?)
    extraSessionCommands = ''
      WLR_DRM_DEVICES="$(if test -d /sys/class/drm/card1/card1-eDP-1; then echo /dev/dri/card1; else echo /dev/dri/card0; fi)"
      export WLR_DRM_DEVICES
    '';
  };

  # List services that you want to enable:
  services.actkbd = {
    enable = false;
    # Don't use sound.mediaKeys.enable, since it execs as root (without
    # XDG_RUNTIME_DIR), and thus cannot connect to ALSA.
    # guiEnv = "XDG_RUNTIME_DIR=/run/user/${toString config.users.users.adam.uid}";
    # wpctl = "${guiEnv} ${pkgs.wireplumber}/bin/wpctl";
    # volumeStep = "2.5%";
    # brillo = "${pkgs.brillo}/bin/brillo";
    # Shift_L = 42;
    # XF86MonBrightnessUp = 232;
    # XF86MonBrightnessDown = 233;
    # XF86AudioMute = 113;
    # XF86AudioMicMute = 190;
    # XF86AudioLowerVolume = 114;
    # XF86AudioRaiseVolume = 115;
    # bindings = builtins.concatLists [
    #   (onKey XF86MonBrightnessUp noRepeat "${brillo} -A 5")
    #   (onKey XF86MonBrightnessDown noRepeat "${brillo} -U 5")
    #   (onKey XF86AudioMute noRepeat "${wpctl} set-mute @DEFAULT_SINK@ toggle")
    #   (onKey XF86AudioMicMute noRepeat "${wpctl} set-mute @DEFAULT_SOURCE@ toggle")
    #   (onKey XF86AudioLowerVolume noRepeat "${wpctl} set-volume @DEFAULT_SINK@ ${volumeStep}-")
    #   (onKey XF86AudioRaiseVolume noRepeat "${wpctl} set-volume @DEFAULT_SINK@ ${volumeStep}+")
    #   (onKey [Shift_L XF86AudioMute] noRepeat "${wpctl} set-mute @DEFAULT_SOURCE@ toggle")
    #   (onKey [Shift_L XF86AudioLowerVolume] noRepeat "${wpctl} set-volume @DEFAULT_SOURCE@ ${volumeStep}-")
    #   (onKey [Shift_L XF86AudioRaiseVolume] noRepeat "${wpctl} set-volume @DEFAULT_SOURCE@ ${volumeStep}+")
    # ];
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_MAX_PERF_ON_AC = 85;
      CPU_MAX_PERF_ON_BAT = 60;
    };
  };

  # throttled doesn't support i9-13900HX.
  # undervolting seems to be locked in firmware.
  services.undervolt = {
    enable = false;
    tempBat = 75;
    tempAc = 80;
    p2.limit = 90;
    p2.window = 1;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [3000 3001];
  networking.firewall.allowedUDPPorts = [3000 3001];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
