{
  config,
  pkgs,
  ...
}: let
  home = config.home.homeDirectory;

  bruno-app = pkgs.callPackage (import ./modules/bruno.nix) {};
  # TODO: Figure out why this overrideAttrs method doesn't work... build output:
  #
  # trying https://github.com/usebruno/bruno/archive/refs/tags/v2.0.1.tar.gz
  #   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
  #                                  Dload  Upload   Total   Spent    Left  Speed
  #
  # 0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  # 0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  #
  # 100 2973k    0 2973k    0     0  7368k      0 --:--:-- --:--:-- --:--:-- 7368k
  # unpacking source archive /build/download.tar.gz
  # mkdir: cannot create directory '/build/unpack': File exists
  #
  #
  #   pkgs.bruno.overrideAttrs (previousAttrs: rec {
  #   version = "2.0.1";
  #
  #   src = pkgs.fetchFromGitHub {
  #     owner = "usebruno";
  #     repo = "bruno";
  #     tag = "v${version}";
  #     hash = pkgs.lib.fakeHash;
  #
  #     inherit (previousAttrs.src) postFetch;
  #   };
  #
  #   npmDepsHash = pkgs.lib.fakeHash;
  # });
in {
  home.packages = with pkgs; [
    _1password-gui
    bruno-app
    clamav
    mu-repo

    # TODO: Fix openaws-vpn-client flake to build with latest nixpkgs
    # openaws-vpn-client
  ];
  home.sessionVariables = {
    TIV_PLATFORM_APPLY_QUIETLY = "1";
  };

  programs.zsh = {
    enable = true;
    zsh-abbr = {
      enable = true;
      abbreviations = {
        ds = "devbox shell";
      };
    };
    envExtra = ''
      export PATH=${home}/work/common/cli/bin:$PATH
    '';
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/work/";
      contents = {
        user.email = "adam@adaptiv.systems";
        user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1e83u2v7t+ePxp3RXARC3tnXiPcC95OLMDi2sdTDAc";
        commit.gpgsign = true;
        gpg = {
          format = "ssh";
          ssh = {
            allowedSignersFile = builtins.toFile "allowed-signers" ''
              adam@adaptiv.systems ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHuKcZZc8H73Brm6B7wIcGuInLH5t48ezXRDw4rurAi
              adam@adaptiv.systems ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1e83u2v7t+ePxp3RXARC3tnXiPcC95OLMDi2sdTDAc
            '';
            program = "${pkgs._1password-gui}/bin/op-ssh-sign";
          };
        };
      };
    }
  ];
  programs.git.extraConfig.url."github-work:adamdicarlo0/".insteadOf = "git@github.com:adamdicarlo0/";
  programs.git.extraConfig.url."github-work:adamdicarlo0/".pushInsteadOf = "git@github.com:adamdicarlo0/";
  programs.git.extraConfig.url."github-work:adaptivsystems/".insteadOf = "git@github.com:adaptivsystems/";
  programs.git.extraConfig.url."github-work:adaptivsystems/".pushInsteadOf = "git@github.com:adaptivsystems/";

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableScDaemon = false;
    enableSshSupport = true;
    sshKeys = ["689797597435372AAE566787A29AFFB7B862D0B6"];
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  programs.ssh.matchBlocks = {
    github-work = {
      hostname = "github.com";
      user = "git";
      identityFile = "${home}/.ssh/id_adaptiv";
      extraOptions = {
        AddKeysToAgent = "yes";
        IdentityAgent = "~/.1password/agent.sock";
      };
    };
    "github.com" = {
      extraOptions = {
        AddKeysToAgent = "yes";
      };
      identityFile = "${home}/.ssh/id_personal";
      user = "git";
    };
  };
}
