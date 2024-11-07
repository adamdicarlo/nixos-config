{
  # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled#switching-to-flake-nix-for-system-configuration
  # nix flake init -t templates#full

  description = "Adam DiCarlo's NixOS Configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://fufexan.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    devbox = {
      url = "github:jetify-com/devbox/0.13.6";
      inputs.flake-utils.follows = "flake-utils";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # openaws-vpn-client and dependency
    openaws-vpn-client = {
      url = "https://github.com/adamdicarlo/openaws-vpn-client/archive/6462f1449875bb26d0866644c3687e4a82b0d4c1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lib-aggregate = {
      url = "github:nix-community/lib-aggregate";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-eval-jobs = {
      url = "github:nix-community/nix-eval-jobs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Common flake dependencies.
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    systems.url = "github:nix-systems/x86_64-linux";
  };

  # `outputs` are all the build result of the flake.
  #
  # A flake can have many use cases and different types of outputs.
  #
  # parameters in function `outputs` are defined in `inputs` and
  # can be referenced by their names. However, `self` is an exception,
  # this special parameter points to the `outputs` itself(self-reference)
  #
  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    inherit (self) outputs;
    system = "x86_64-linux";

    overlays = import ./overlays {
      inherit inputs outputs system;
      inherit (nixpkgs) lib;
    };
  in {
    nixosConfigurations = {
      carbo = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ({lib, ...}: {
            # Beware: https://github.com/NixOS/nixpkgs/issues/191910
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = overlays;
          })
          inputs.agenix.nixosModules.default
          inputs.disko.nixosModules.disko
          ./machines/carbo/default.nix
        ];
      };

      oddsy = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          inputs.agenix.nixosModules.default
          inputs.disko.nixosModules.disko
          ./machines/oddsy/default.nix
        ];
      };

      opti = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ({lib, ...}: {
            nixpkgs.config.allowUnfree = true;
          })
          inputs.agenix.nixosModules.default
          ./machines/opti/default.nix
        ];
      };

      # By default, NixOS will try to refer the nixosConfiguration with
      # its hostname. However, the configuration name can also be specified using:
      #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
      tiv = nixpkgs.lib.nixosSystem {
        # Each parameter in `modules` is a Nix Module, and there is a partial
        # introduction to it in the nixpkgs manual:
        #   <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
        #
        # A Nix Module can be an attribute set, or a function that
        # returns an attribute set. By default, if a Nix Module is a
        # function, this function can only have the following parameters:
        #
        # - `lib`: the nixpkgs function library, which provides many
        #   useful functions for operating on Nix expressions:
        #   https://nixos.org/manual/nixpkgs/stable/#id-1.4
        # - `config`: all config options of the current flake, every useful
        # - `options`: all options defined in all NixOS Modules
        #   in the current flake
        # - `pkgs`: a collection of all packages defined in nixpkgs,
        #   plus a set of functions related to packaging.
        #   you can assume its default value is
        #   `nixpkgs.legacyPackages."${system}"` for now.
        #   can be customed by `nixpkgs.pkgs` option.
        # - `modulesPath`: the default path of nixpkgs's modules folder,
        #   used to import some extra modules from nixpkgs.
        #   this parameter is rarely used,
        #   you can ignore it for now.
        #
        # Only these parameters can be passed by default.
        # If you need to pass other parameters, you must use `specialArgs`.
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ({lib, ...}: {
            # Beware: https://github.com/NixOS/nixpkgs/issues/191910
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = overlays;
          })
          inputs.agenix.nixosModules.default
          ./machines/tiv/default.nix
        ];
      };
    };

    homeConfigurations = let
      extraSpecialArgs = {inherit inputs outputs mkAbsoluteSymlink system;};
      pkgs = import nixpkgs {
        config = {allowUnfree = true;};
        inherit overlays;
        inherit system;
      };

      # Adapted from https://github.com/robbert-vdh/dotfiles/blob/129432dab00500eaeaf512b1d5003a102a08c72f/flake.nix#L71-L77
      # TODO: Use impurity.nix instead?
      # https://github.com/outfoxxed/impurity.nix/blob/master/default.nix
      mkAbsoluteSymlink = let
        nixosConfigPath = "/home/adam/nixos-config";
      in
        # FIXME: I couldn't figure out how to define this in a module so we
        #        don't need to pass config in here
        config: repoRelativePath: let
          fullPath = "${nixosConfigPath}/${repoRelativePath}";
          assertion =
            pkgs.lib.asserts.assertMsg (builtins.pathExists fullPath)
            "mkAbsoluteSymlink: '${fullPath}' does not seem to exist";
        in
          assert assertion; config.lib.file.mkOutOfStoreSymlink fullPath;

      laptop = username: hostname: extras: {
        "${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = extraSpecialArgs // {inherit hostname username;};
          modules =
            [
              ./home-manager/home.nix
              ./home-manager/gui.nix
            ]
            ++ extras;
        };
        "root@${hostname}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs =
            extraSpecialArgs
            // {
              inherit hostname;
              username = "root";
            };
          modules = [./home-manager/home.nix];
        };
      };

      server = username: hostname: {
        "${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = extraSpecialArgs // {inherit hostname username;};
          modules = [./home-manager/home.nix];
        };
        "root@${hostname}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs =
            extraSpecialArgs
            // {
              inherit hostname;
              username = "root";
            };
          modules = [./home-manager/home.nix];
        };
      };
    in
      {}
      // server "adam" "oddsy"
      // server "adam" "opti"
      // laptop "adam" "tiv" [./home-manager/adaptiv.nix]
      // laptop "adam" "carbo" [];
  };
}
