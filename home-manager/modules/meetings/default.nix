# Modal meeting reminders and a "next meeting" bar module, from Google
# Calendar via gcalcli.
#
# One-time setup (needs your own Google OAuth client ID):
#   gcalcli --client-id=<id>.apps.googleusercontent.com init
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Meetings only start on the quarter hour, so check once per quarter, this
  # many minutes before it.
  leadMinutes = 2;
  checkMinutes =
    map (q: lib.fixedWidthNumber 2 (lib.mod (q - leadMinutes + 60) 60))
    [0 15 30 45];

  # Only alert for (and show) events on this calendar: the primary one, not
  # the subscribed ones.
  calendar = "Luminary";

  python = pkgs.python3.withPackages (ps: [ps.pygobject3]);

  meetings = pkgs.stdenv.mkDerivation {
    name = "meetings";
    src = ./meetings.py;
    dontUnpack = true;

    nativeBuildInputs = [pkgs.gobject-introspection pkgs.wrapGAppsHook4];
    buildInputs = [pkgs.gtk4 pkgs.gtk4-layer-shell];

    installPhase = ''
      install -Dm755 $src $out/bin/meetings
      sed -i '1s|.*|#!${python}/bin/python3|' $out/bin/meetings
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix PATH : ${lib.makeBinPath [pkgs.gcalcli pkgs.xdg-utils]}
        --set MEETINGS_LAYER_SHELL_LIB ${pkgs.gtk4-layer-shell}/lib/libgtk4-layer-shell.so
        --set MEETINGS_SELF $out/bin/meetings
        --set MEETINGS_LEAD_MINUTES ${toString leadMinutes}
        --set MEETINGS_CALENDAR ${lib.escapeShellArg calendar}
      )
    '';
  };
  meetingsBin = lib.getExe' meetings "meetings";
in {
  home.packages = [pkgs.gcalcli meetings];

  systemd.user.services.meetings-check = {
    Unit.Description = "Check Google Calendar for upcoming meetings";
    Service = {
      Type = "oneshot";
      # With only one check per quarter hour, retry a failed fetch (e.g. a
      # network blip) while there's still time to alert.
      Restart = "on-failure";
      RestartSec = "20s";
      ExecStart = "${meetingsBin} check";
    };
  };

  systemd.user.timers.meetings-check = {
    Unit = {
      Description = "Check Google Calendar before each quarter hour";
      PartOf = [config.wayland.systemd.target];
      After = [config.wayland.systemd.target];
    };
    Timer = {
      OnCalendar = "*:${lib.concatStringsSep "," checkMinutes}:00";
      AccuracySec = "5s";
    };
    Install.WantedBy = [config.wayland.systemd.target];
  };

  # runtime.toml (written by the Wayle settings GUI) takes precedence over
  # this; run `wayle config reset bar.layout` if the module doesn't appear.
  services.wayle.settings = {
    bar.layout = [
      {
        monitor = "*";
        show = true;
        left = ["sway-workspaces"];
        center = ["custom-meeting" "media"];
        right = [
          "idle-inhibit"
          "notifications"
          "microphone"
          "volume"
          "battery"
          "systray"
          "clock"
        ];
      }
    ];

    modules.custom = [
      {
        id = "meeting";
        command = "${meetingsBin} bar";
        interval-ms = 30000;
        icon-name = "tb-calendar-time-symbolic";
        icon-map = {
          now = "ld-clock-symbolic";
          error = "tb-calendar-time-symbolic";
        };
        class-format = "meeting-{{ alt }}";
        label-max-length = 45;
        left-click = "${meetingsBin} join";
        right-click = "${lib.getExe' pkgs.xdg-utils "xdg-open"} https://calendar.google.com/";
        on-action = "${meetingsBin} bar";
      }
    ];
  };
}
