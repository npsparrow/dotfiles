{ config, pkgs, ... }:

{
  imports = [ 
    ./wm
    ./shell
    ./emacs
    # ./kitty
    ./programs
    # etc.
  ];

  home = {
    username = "nikhil";
    homeDirectory = "/home/nikhil";
    sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";

      STEAM_API_KEY = "7EDE7F4E57DB19E978AD9B05FC00A412";
      LESSHISTFILE = "-";
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
