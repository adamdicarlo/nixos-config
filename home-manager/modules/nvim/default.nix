{ config, mkAbsoluteSymlink, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [ shfmt ];
  };

  xdg.configFile.nvim = {
    recursive = true;
    source = mkAbsoluteSymlink config "home-manager/modules/nvim/config";
  };
}
