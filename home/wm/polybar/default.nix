{ pkgs, ... }:
{
  imports = [
    ./colors.nix
  ];
  services.polybar = { 
    enable = true;
    script = "";
    settings = {
      "bar/one" = {
        width = "7%";
        height = 28;
        offset-x = 5;
        offset-y = 5;
        radius = 12.0;
        font-0 = "LilexNerdFontMono:style=Bold:size=11;3";
        background = "\${colors.base}";
        foreground = "#fff";
        modules-center = "date";
      };

      "module/date" = {
        type = "internal/date";
        date = "%Y-%m-%d%";
      };

      "bar/two" = {
        width = "6%";
        height = 28;
        offset-x = "47%";
        offset-y = 5;
        radius = 12.0;
        font-0 = "LilexNerdFontMono:style=Bold:size=11;3";
        background = "\${colors.base}";
        foreground = "#fff";
        modules-center = "date";
      };
    };
  };
}
