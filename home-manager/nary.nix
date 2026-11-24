{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  home = config.home.homeDirectory;
in {
  home.packages = with pkgs; [
    amp-desktop
    google-chrome
    linear-desktop
  ];
  xdg.configFile."gcalcli/config.toml" = {
    text = ''
      [calendars]
      default-calendars = ["Luminary"]
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = pkgs.lib.mkForce "33694+adamdicarlo0@users.noreply.github.com";
      };
    };
  };
}
