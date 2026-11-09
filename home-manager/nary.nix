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
  ];
  xdg.configFile."gcalcli/config.toml" = {
    text = ''
      [calendars]
      default-calendars = ["Luminary"]
    '';
  };
}
