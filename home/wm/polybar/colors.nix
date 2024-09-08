{ pkgs, ... }:
{
  services.polybar.settings = {
    "colors" = {
      background = "#1F1F1F";
      foreground = "#FFFFFF";
      foreground-alt = "#8F8F8F";
      module-fg = "#FFFFFF";
      primary = "#5e35b1";
      secondary = "#E53935";
      alternate = "#aeb3f2";

      base = "#1e1e2e";
      mantle = "#181825";
      crust = "#11111b";

      text = "#cdd6f4";
      subtext0 = "#a6adc8";
      subtext1 = "#bac2de";

      surface0 = "#313244";
      surface1 = "#45475a";
      surface2 = "#585b70";

      overlay0 = "#6c7086";
      overlay1 = "#7f849c";
      overlay2 = "#9399b2";


      blue = "#89b4fa";
      lavender = "#b4befe";
      sapphire = "#74c7ec";
      sky = "#89dceb";
      teal = "#94e2d5";
      green = "#a6e3a1";
      yellow = "#f9e2af";
      peach = "#fab387";
      maroon = "#eba0ac";
      red = "#f38ba8";
      mauve = "#cba6f7";
      pink = "#f5c2e7";
      flamingo = "#f2cdcd";
      rosewater = "#f5e0dc";

      transparent = "#FF00000";
    };
  };
}
