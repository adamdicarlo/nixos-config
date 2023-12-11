{
  # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled#switching-to-flake-nix-for-system-configuration
  # nix flake init -t templates#full

  description = "Adam DiCarlo's NixOS Configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://fufexan.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";

      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.darwin.follows = "";
    };

    nur.url = "github:nix-community/NUR";

    # https://github.com/NixOS/nix/issues/3978#issuecomment-1661075896
    devbox.url = "github:adamdicarlo/devbox-nix-flake";
    devbox.inputs.nixpkgs.follows = "nixpkgs";
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
    devbox,
    nixpkgs,
    agenix,
    home-manager,
    nur,
    ...
  }: let
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = let
      devboxOverlay = final: prev: {
        # Is there a simpler way to do this?
        devbox = devbox.outputs.defaultPackage.${system};
      };

      hmConfigModule = {
        home-manager.backupFileExtension = "hm-backup";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      };
    in {
      opti = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          {nixpkgs.overlays = [devboxOverlay];}

          hmConfigModule
          ./machines/opti/default.nix
        ];
      };

      # By default, NixOS will try to refer the nixosConfiguration with
      # its hostname. However, the configuration name can also be specified using:
      #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
      tiv = nixpkgs.lib.nixosSystem {
        inherit system;
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
          nur.nixosModules.nur

          {
            nixpkgs.overlays = [
              nur.overlay
              devboxOverlay
              inputs.nixpkgs-wayland.overlay
            ];
          }

          agenix.nixosModules.default
          hmConfigModule
          ./machines/tiv/default.nix
        ];
      };
    };

    homeConfigurations = let
      # Adapted from https://github.com/robbert-vdh/dotfiles/blob/129432dab00500eaeaf512b1d5003a102a08c72f/flake.nix#L71-L77
      mkAbsoluteSymlink = let
        # This needs to be set for the `mkAbsolutePath` function
        # defined below to work. It's set in the Makefile, and
        # requires the nix build to be run with `--impure`.
        dotfilesPath = let
          path = builtins.getEnv "NIXOS_CONFIG_PATH";
          assertion =
            pkgs.lib.asserts.assertMsg
            (path != "" && pkgs.lib.filesystem.pathIsDirectory path)
            "NIXOS_CONFIG_PATH='${path}' but must be set to this file's directory. Use 'make' to run this build.";
        in
          assert assertion; path;
      in
        # This is a super hacky way to get absolute paths from a Nix path.
        # Flakes intentionally don't allow you to get this information, but we
        # need this to be able to use `mkOutOfStoreSymlink` to create regular
        # symlinks for configurations that should be mutable, like for Emacs'
        # config and for fonts. This relies on `NIXOS_CONFIG_PATH`
        # pointing to the directory that contains this file.
        # FIXME: I couldn't figure out how to define this in a module so we
        #        don't need to pass config in here
        config: repoRelativePath: let
          fullPath = "${dotfilesPath}/${repoRelativePath}";
          assertion =
            pkgs.lib.asserts.assertMsg (builtins.pathExists fullPath)
            "'${fullPath}' does not exist (make sure --impure is enabled)";
        in
          assert assertion; config.lib.file.mkOutOfStoreSymlink fullPath;
    in {
      "adam@tiv" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs outputs mkAbsoluteSymlink;};
        modules = [
          ./home-manager/home.nix
          ./home-manager/gui.nix
          ./home-manager/adaptiv.nix
        ];
      };

      "adam@opti" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs outputs mkAbsoluteSymlink;};
        modules = [
          ./home-manager/home.nix
        ];
      };
    };
  };
}
