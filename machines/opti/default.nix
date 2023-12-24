{pkgs, ...}: {
  imports = [./hardware.nix ../common.nix];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "opti";

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
  ];

  services.adguardhome = {
    enable = true;

    # open ports for web interface
    openFirewall = true;

    settings = rec {
      http = {
        address = "${bind_host}:${builtins.toString bind_port}";
      };
      bind_host = "0.0.0.0";
      bind_port = 5300;
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [53 80 443];
  networking.firewall.allowedUDPPorts = [53];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?
}
