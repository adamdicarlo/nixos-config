{lib, ...}: let
  colors = {
    # Dracula colors (https://spec.draculatheme.com/)
    # Hybrid of Standard and ANSI palettes.
    background = "#282A36";
    black = "#21222C";
    red = "#FF5555";
    green = "#50FA7B";
    gray = "#44475A";
    orange = "#FFB86C";
    yellow = "#F1FA8C";
    blue = "#6272A4";
    purple = "#BD93F9";
    pink = "#FF79C6";
    cyan = "#8BE9FD";
    white = "#F8F8F2";
    brightBlack = "#6272A4";
    brightRed = "#FF6E6E";
    brightGreen = "#69FF94";
    brightYellow = "#FFFFA5";
    brightPurple = "#D6ACFF";
    brightPink = "#FF92DF";
    brightCyan = "#A4FFFF";
    brightWhite = "#FFFFFF";

    # Custom extra colors.
    dimWhite = "#B8B8B2";
  };

  toDecimalString = hex: builtins.toString (lib.fromHexString hex);
in
  # We export 'colors' plus:
  # - a 'u' copy without the # prefix
  # - a 'd' copy as decimal "R,G,B" strings (weird format for kmscon)
  colors
  // {
    u = builtins.mapAttrs (_name: value: builtins.substring 1 (-1) value) colors;
    d =
      builtins.mapAttrs (
        _name: value:
          builtins.concatStringsSep ","
          [
            (toDecimalString (builtins.substring 1 2 value))
            (toDecimalString (builtins.substring 3 2 value))
            (toDecimalString (builtins.substring 5 2 value))
          ]
      )
      colors;
  }
