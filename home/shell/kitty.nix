{config, pkgs, ...}: 
{
  programs.kitty = {
    enable = true;
    font.name = "Maple Mono NF";
    font.size = 13;
    themeFile = "Catppuccin-Mocha";
    shellIntegration = {
      enableZshIntegration = true;
      mode = "no-cursor";
    };
    settings = {
      enable_audio_bell = false;
      visual_bell_duration = 0;

      window_padding_width = "0 2";
    };
  };
}
