{
  hostname,
  lib,
  pkgs,
  ...
}: let
  isPersonalMachine = hostname == "carbo";
in {
  home.packages = with pkgs; [
    cantarell-fonts
    font-awesome
    font-awesome_5
    nwg-clipman
    nwg-menu
    nwg-panel
  ];
}
