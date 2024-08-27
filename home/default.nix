{ config, pkgs, ... }:

{
  imports = [ 
    ./wm
    ./shell
    ./emacs
    ./programs
  ];

  home = {
    username = "nikhil";
    homeDirectory = "/home/nikhil";
    pointerCursor = {
      name = "phinger-cursors-dark";
      package = pkgs.phinger-cursors;
      size = 16;
      gtk.enable = true;
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
