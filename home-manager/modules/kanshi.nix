{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "dell-ultrawide";
        profile.outputs = [
          {
            criteria = "Dell Inc. DELL U3821DW HH7YZ63";
            status = "enable";
            mode = "3840x1600@30Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      }
      {
        profile.name = "lg-ultrawide";
        profile.outputs = [
          {
            criteria = "Goldstar Company Ltd LG HDR WQHD 0x0000B6E2";
            status = "enable";
            mode = "3440x1440@60Hz";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      }
      {
        profile.name = "x1c7-undocked";
        profile.outputs = [
          {
            criteria = "BOE 0x07C8 Unknown";
            status = "enable";
            mode = "3840x2160@60Hz";
            position = "0,0";
            scale = 2.0;
          }
        ];
      }
      {
        profile.name = "addw3-undocked";
        profile.outputs = [
          {
            criteria = "BOE 0x08B3 Unknown";
            status = "enable";
            mode = "1920x1080@144Hz";
            position = "0,0";
            scale = 1.0;
          }
        ];
      }
    ];
  };
}
