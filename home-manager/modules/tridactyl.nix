{...}: {
  xdg.configFile."tridactyl/tridactylrc" = {
    text = ''
      " General Settings
      set update.lastchecktime 1707540851635
      set update.nag true
      set update.nagwait 7
      set update.lastnaggedversion 1.14.0
      set update.checkintervalsecs 86400
      set configversion 2.0

      bind j scrollpx -50
      bind J back
      bind --mode=visual J back

      bind H tabprev
      bind --mode=visual H tabprev
      bind h scrollline -10

      bind K tabnext
      bind --mode=visual K tabnext
      bind k scrollline 10

      " Defaults
      " bind --mode=visual h js document.getSelection().modify("extend","backward","character")
      " bind --mode=visual l js document.getSelection().modify("extend","forward","character")
      " bind --mode=visual j js document.getSelection().modify("extend","forward","line")
      " bind --mode=visual k js document.getSelection().modify("extend","backward","line")

      bind --mode=visual j js document.getSelection().modify("extend", "backward", "character")
      bind --mode=visual l js document.getSelection().modify("extend", "forward", "character")
      bind --mode=visual h js document.getSelection().modify("extend", "backward", "line")
      bind --mode=visual k js document.getSelection().modify("extend", "forward", "line")

      " For syntax highlighting see https://github.com/tridactyl/vim-tridactyl
      " vim: set filetype=tridactyl
    '';
  };
}
