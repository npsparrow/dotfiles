{ pkgs, config, ... }: 
{
  imports = [
    ./polybar
  ];


  home.packages = [
    pkgs.rofi
    pkgs.betterlockscreen
  ];

  # wallpaper, bspwmrc
  home.file.".config/bspwm" = {
    source = ./bspwm;
    recursive = true;
  };
  # sxhkdrc
  home.file.".config/sxhkd" = {
    source = ./sxhkd;
    recursive = true;
  };

  # Install picom and enable its service
  services.picom = {
    enable = true;
    opacityRules = [
      "95:class_g = 'kitty' && focused"
      "80:class_g = 'kitty' && !focused"
    ];
  };

  # install rofi and configure
  home.file.".config/rofi" = {
    source = ./rofi;
    recursive = true;
  };

  # betterlockscreen
  home.file.".config/betterlockscreen" = {
    source = ./betterlockscreen;
    recursive = true;
  };

  # dunst
  services.dunst.enable = true;
}
