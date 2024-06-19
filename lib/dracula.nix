let
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
  # colors plus a 'u' attribute containing the colors without the # prefix
in (colors // {u = builtins.mapAttrs (name: value: builtins.substring 1 (-1) value) colors;})
