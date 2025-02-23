{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        rust-overlay.follows = "rust-overlay";
      };
    };
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/x86_64-linux";

    # Modular, extensible and distro-agnostic NeoVim configuration framework
    # https://github.com/NotAShelf/nvf
    nvf = {
      url = "github:notashelf/nvf";
      inputs = {
        flake-parts.follows = "flake-parts";
        flake-utils.follows = "flake-utils";
        nil.follows = "nil";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;

    # An abstraction over systems to easily provide the same package
    # for multiple systems. This is preferable to abstraction libraries.
    forEachSystem = lib.genAttrs ["x86_64-linux"];
  in {
    packages = forEachSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      # Evaluate any and all modules to create the wrapped NeoVim package.
      myNeoVim = inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;

        modules = [
          # Configuration module to be imported. You may define multiple modules
          # or even import them from other files (e.g., ./modules/lsp.nix) to
          # better modularize your configuration.
          (import ./config.nix {inherit lib;})
        ];
      };
    in rec {
      # Packages to be exposed under packages.<system>. Those can accessed
      # directly from package outputs in other flakes if this flake is added
      # as an input. You may run those packages with 'nix run .#<package>'
      neovimConfigured = myNeoVim.neovim;
      default = neovimConfigured;
    });
  };
}
