{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [ shfmt ];
  };

  xdg.configFile.nvim = {
    recursive = true;
    source = ./config;
    target = "nvim";
  };
}
