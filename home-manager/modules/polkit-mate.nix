{pkgs, ...}: {
  # Adapted from https://github.com/Madic-/Sway-DE/blob/master/config/systemd/user/polkit-gnome.service.j2
  systemd.user.services.polkit-mate = {
    Unit = {
      Description = "Graphical Polkit authentication agent";
      PartOf = ["sway-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
      ExecStop = "kill -2 $MAINPID";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = ["sway-session.target"];
    };
  };
}
