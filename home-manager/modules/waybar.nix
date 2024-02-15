{pkgs, ...}: {
  home.packages = with pkgs; [
    waybar
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        # From https://github.com/Pipshag/dotfiles_nord/blob/master/.config/waybar/config
        "layer" = "top"; # Waybar at top layer
        "position" = "top"; # Waybar position (top|bottom|left|right)
        # "height" = 36; # Waybar height (to be removed for auto height)
        # Archived modules
        # "custom/gpu" "bluetooth"  "custom/weather" "temperature" "sway/window"
        # Choose the order of the modules
        "modules-left" = [
          "sway/workspaces"
          # "custom/scratchpad-indicator"
          "sway/mode"
          "wlr/taskbar"
        ];
        "modules-center" = ["sway/window"];
        "modules-right" = [
          "cpu"
          "temperature#cpu"
          "temperature#gpu"
          "idle_inhibitor"
          "backlight"
          "pulseaudio"
          "privacy"
          # "bluetooth"
          "network"
          "battery"
          "tray"
          "clock"
        ];
        # Modules configuration
        "sway/workspaces" = {
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "<span color=\"#D8DEE9\">  </span>";
            "2" = "<span color=\"#88C0D0\">  </span>";
            "3" = "<span color=\"#D8DEE9\">  </span>";
            "4" = "<span color=\"#A3BE8C\">  </span>";
            urgent = "";
            focused = "";
            default = "";
          };
        };
        "sway/mode" = {
          tooltip = false;
        };
        "backlight" = {
          device = "acpi_video0";
        };
        bluetooth = {
          "interval" = 30;
          "format" = "{icon}";
          # "format-alt" = "{status}";
          "format-icons" = {
            "enabled" = "";
            "disabled" = "";
          };
          "on-click" = "blueberry";
        };
        "idle_inhibitor" = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = " ";
          };
          tooltip = true;
        };
        "tray" = {
          #"icon-size = 11;
          spacing = 6;
        };
        "clock" = {
          "format" = "  {:%r     %b %e}";
          "tooltip-format" = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          "today-format" = "<b>{}</b>";
          "on-click" = "";
        };
        "cpu" = {
          "interval" = "1";
          "format" = "  {max_frequency}GHz <span color=\"darkgray\">| {usage}%</span>";
          "max-length" = 13;
          "min-length" = 13;
          "on-click" = "${pkgs.sway}/bin/swaymsg exec \"${pkgs.kitty}/bin/kitty -e btop\"";
          "tooltip" = false;
        };
        "temperature#cpu" = {
          "thermal-zone" = 0;
          "interval" = "2";
          # "hwmon-path" = "/sys/class/hwmon/hwmon3/temp1_input";
          "critical-threshold" = 80;
          "format-critical" = "  {temperatureC}°C";
          "format" = "{icon}  {temperatureC}°C";
          "format-icons" = [""];
          "max-length" = 7;
          "min-length" = 7;
        };
        "temperature#gpu" = {
          thermal-zone = 1;
          interval = "2";
          # "hwmon-path" = "/sys/class/hwmon/hwmon3/temp1_input";
          critical-threshold = 74;
          format-critical = "  {temperatureC}°C";
          format = "{icon}  {temperatureC}°C";
          format-icons = [""];
          max-length = 7;
          min-length = 7;
        };
        network = {
          # "interface" = "wlan0", # (Optional) To force the use of this interface,
          format-wifi = " ";
          format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          family = "ipv4";
          tooltip-format-wifi = "  {ifname} @ {essid}\nIP: {ipaddr}\nStrength: {signalStrength}%\nFreq: {frequency}MHz\n {bandwidthUpBits}  {bandwidthDownBits}";
          tooltip-format-ethernet = " {ifname}\nIP: {ipaddr}\n {bandwidthUpBits}  {bandwidthDownBits}";
        };
        privacy = {
          icon-spacing = 4;
          icon-size = 18;
          transition-duration = 350;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-out";
              tooltip = true;
              tooltip-icon-size = 24;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 24;
            }
          ];
        };
        pulseaudio = {
          scroll-step = 2.5; # %, can be a float
          format = "{icon}  {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          #"format-source-muted" = "";
          # format-source = "";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = ["" "" ""];
          };
          on-click = "${pkgs.sway}/bin/swaymsg exec \"${pkgs.pavucontrol}/bin/pavucontrol\"";
          on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SOURCE@ toggle";
        };
        battery = {
          states = {
            warning = 25;
            critical = 10;
          };
          format = " {icon}   {capacity}% ";
          format-alt = " {time}  {icon}  ";
          format-icons = ["" "" "" "" ""];
          format-time = "{H}:{M}";
          tooltip = false;
          interval = 20;
        };
      };
    };
  };
}
