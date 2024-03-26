{ pkgs, config, ... }: 
{
  imports = [
    ./polybar.nix
  ];

  # wallpaper, binary, sxhkdrc
  home.file.".config/bspwm/wallpaper.jpg".source = ./walls/mononoke.jpg;
  home.file.".config/sxhkd/sxhkdrc".source = ./sxhkdrc;
  home.file.".config/bspwm/bspwmrc" = {
    source = ./bspwmrc;
    executable = true;
  };

  # Install picom and enable its service
  services.picom = {
    enable = true;
    opacityRules = [
      "95:class_g = 'kitty' && focused"
      "80:class_g = 'kitty' && !focused"
    ];
  };

  home.packages = [ pkgs.rofi ];
  home.file.".config/rofi/sparrow.rasi".source = ./sparrow.rasi;
}
