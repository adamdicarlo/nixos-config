{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.swappy;
in {
  options.programs.swappy = {
    enable = mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Whether to enable swappy.
      '';
    };
    package = mkPackageOption pkgs "swappy" {};
  };

  home.packages = [cfg.package];

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "programs.swappy" pkgs
        lib.platforms.linux)
    ];

    xdg.configFile."swappy/config" =
      mkIf (cfg.settings != {}) {
      };
  };
}
