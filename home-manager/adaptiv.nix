{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    _1password-gui
  ];

  programs.zsh.initExtra = ''
    # Automatically run devbox shell when entering adaptiv repos
    eval "$(/home/adam/work/localtools/scripts/cd-devbox)"
  '';

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
  programs.git.extraConfig.url."github-work:adaptivsystems/".insteadOf = "git@github.com:adaptivsystems/";
  programs.git.extraConfig.url."github-work:adaptivsystems/".pushInsteadOf = "git@github.com:adaptivsystems/";

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableScDaemon = false;
    enableSshSupport = true;
    sshKeys = ["689797597435372AAE566787A29AFFB7B862D0B6"];
  };

  programs.ssh.matchBlocks = {
    github-work = {
      hostname = "github.com";
      user = "git";
      identityFile = "/home/adam/.ssh/id_adaptiv";
      extraOptions = {
        AddKeysToAgent = "yes";
        IdentityAgent = "~/.1password/agent.sock";
      };
    };
  };
}
