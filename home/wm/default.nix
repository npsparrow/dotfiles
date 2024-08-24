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
  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "Lilex Nerd Font Mono Regular 14";
        allow_markup = "yes";
        markup = "yes";
        format = "<span foreground='#5bb1b4'><b>%s</b></span>\n%b";
        sort = "yes";
        indicate_hidden = "yes";
        bounce_freq = 0;
        show_age_threshold = 60;
        word_wrap = "yes";
        ignore_newline = false;
        origin = "top-right";
        transparency = 0;
        idle_threshold = 120;
        monitor = 0;
        follow = "mouse";
        sticky_history = "yes";
        line_height = 0;
        separator_height = 2;
        padding = 12;
        horizontal_padding = 12;
        separator_color = "#3c4549";
        separator_width = 1;
        startup_notification = false;
        corner_radius = 15;
        frame_color = "#3c4549";
        frame_width = 1;
        width = 400;
        progress_bar_max_width = 400;
        progress_bar_min_width = 400;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_corner_radius = 5;
        scale = 1;
        min_icon_size = 64;
        max_icon_size = 64;
        alignment = "center";
        vertical_alignment = "center";
        offset = "30x30";
      };

      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };

      urgency_low = {
        background = "#131519";
        foreground = "#ffffff";
        highlight = "#5bb1b4";
        timeout = 5;
      };

      urgency_normal = {
        background = "#131519";
        foreground = "#ffffff";
        highlight = "#5bb1b4";
        timeout = 20;
      };

      urgency_critical = {
        background = "#131519";
        foreground = "#ffffff";
        highlight = "#5bb1b4";
        timeout = 0;
      };

    };
  };
  
}
