{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../common.nix
    ../laptop.nix
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.system76
  ];

  services.system76-scheduler.enable = true;

  services.clamav.daemon = let
    onVirusEvent =
      pkgs.writeTextFile
      {
        name = "on-virus-event";
        executable = true;
        destination = "/bin/on-virus-event.sh";
        # Script based on https://github.com/Cisco-Talos/clamav/issues/1062#issuecomment-1771546865 (2024-06-04)
        text = ''
          #!/usr/bin/env bash
          ALERT="Signature detected by clamav: $CLAM_VIRUSEVENT_VIRUSNAME in $CLAM_VIRUSEVENT_FILENAME"
          echo "$ALERT"
          # Send an alert to all graphical users.
          for ADDRESS in /run/user/*; do
            USERID=''${ADDRESS#/run/user/}
            # We must use the wrapper (which has setuid)
            /run/wrappers/bin/sudo -u "#$USERID" DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS/bus" \
              ${lib.getExe pkgs.libnotify} \
                --app-name=clamav-alert \
                --urgency=critical \
                "VIRUS DETECTED" \
                "$ALERT"
          done
        '';
      };
  in {
    enable = true;
    settings = {
      OnAccessIncludePath = ["/home" "/var/lib" "/tmp"];
      # Exclude accesses by the clamav daemon user and root (onacc user) to
      # avoid infinite scanning loops.
      OnAccessExcludeRootUID = "yes";
      OnAccessExcludeUname = ["clamav"];

      OnAccessExcludePath = [
        # The volumes in /var/lib/docker can't be watched, and fail clamonacc
        "/var/lib/docker"
        # These paths seem to be problematic too
        "/var/lib/containerd"
      ];
      MaxThreads = 2;
      MaxQueue = 16;
      VirusEvent = "${onVirusEvent}/bin/on-virus-event.sh";
    };
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = lib.mkForce (1024 * 1024); # default:  8192
    "fs.inotify.max_user_instances" = lib.mkForce (256 * 1024); # default: 128
  };

  systemd.services.clamav-onacc = {
    description = "ClamAV daemon (clamd)";
    after = ["clamav-daemon.service"];
    requires = ["clamav-daemon.service"];
    wantedBy = ["multi-user.target"];
    restartTriggers = [pkgs.clamav];

    serviceConfig = {
      ExecReload = "${pkgs.coreutils}/bin/kill -USR2 $MAINPID";
      ExecStart = "${pkgs.clamav}/bin/clamonacc --foreground --wait --fdpass";
      PrivateDevices = "yes";
      PrivateNetwork = "yes";
      PrivateTmp = "yes";
      Restart = "on-failure";
      RestartSec = "15s";
      Slice = "system-clamav.slice";
      StateDirectory = "clamav";
      User = "root";
    };
  };

  services.clamav.updater = {
    enable = true;
    frequency = 3;
    interval = "daily";
  };

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 4;
    };
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices."luks-89774725-33d7-4569-98ca-969947979248".device = "/dev/disk/by-uuid/89774725-33d7-4569-98ca-969947979248";

    # Support building arm64 Docker images.
    binfmt.emulatedSystems = ["aarch64-linux"];

    blacklistedKernelModules = ["nouveau" "nvidia"];
  };

  virtualisation.containerd.enable = true;
  virtualisation.docker.daemon.settings = {
    features = {
      # https://docs.docker.com/build/building/multi-platform/#enable-the-containerd-image-store
      containerd-snapshotter = true;
    };
  };

  # Need to create a custom builder (and set it as the default builder)
  system.activationScripts.ensureDockerBuildxBuilder = {
    deps = ["etc"];
    text = let
      docker = lib.getExe pkgs.docker;
    in ''
      ${docker} buildx inspect container-builder &>/dev/null || \
        ${docker} buildx create --name container-builder \
          --driver docker-container --use --bootstrap
    '';
  };
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

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        google-chrome-stable
        vivaldi
        zen
      '';
      mode = "0755";
    };
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
  security.sudo.extraRules = [
    {
      users = ["adam"];
      runAs = "root";
      commands = [
        {
          command = "/home/adam/work/localtools/.devbox/nix/profile/default/bin/traefik";
          options = ["NOPASSWD" "SETENV"];
        }
      ];
    }
    {
      users = ["clamav"];
      runAs = "adam";
      commands = [
        {
          command = lib.getExe pkgs.libnotify;
          options = ["NOPASSWD" "SETENV"];
        }
      ];
    }
  ];

  programs.sway = {
    enable = true;
    extraOptions = [
      "--unsupported-gpu"
    ];
    # Render via the iGPU (intel device) only! (Is --unsupported-gpu actually necessary?)
    # Usually the graphics cards come up as /dev/dri/card{0,1}... but sometimes
    # they are /dev/dri/card{1,2}! (sigh)
    #
    # 0x10de is NVIDIA's vendor ID.
    extraSessionCommands = ''
      WLR_DRM_DEVICES=$(
        [ -e /sys/class/drm/card0/device/vendor ] &&
          (grep -q 0x10de /sys/class/drm/card0/device/vendor && echo /dev/dri/card1 || echo /dev/dri/card0) ||
          (grep -q 0x10de /sys/class/drm/card1/device/vendor && echo /dev/dri/card2 || echo /dev/dri/card1)
      )
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
      CPU_MAX_PERF_ON_AC = 90;
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
  networking.firewall = {
    # 80, 443 so a lambda container (run by SAM) can access traefik on host;
    # 3000, 3001 are for `sam local`.
    allowedTCPPorts = [80 443 3000 3001];
    allowedUDPPorts = [80 443 3000 3001];

    # Allow traffic from a lambda container to access (traefik on) the host.
    # https://discourse.nixos.org/t/docker-container-not-resolving-to-host/30259/8
    extraCommands = ''
      iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
      iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
    '';
  };

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
