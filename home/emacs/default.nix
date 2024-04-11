{ pkgs, config, ... }:
let
  LSPs = [
    pkgs.clang
    pkgs.nil
    pkgs.nodePackages.pyright
  ];
in {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    # query packages with `nix-env -f '<nixpkgs>' -qaP -A emacsPackages`
    extraPackages = epkgs: with epkgs; [
      use-package
      which-key
      helpful
      magit
      # exec-path-from-shell
      undo-tree
      # sudo-edit

      treesit-auto
      catppuccin-theme
      rainbow-delimiters
      doom-modeline
      nerd-icons
      # nerd-icons-dired
      # nerd-icons-ibuffer
      
      # treemacs

      evil
      evil-collection
      evil-surround

      hydra
      general

      vertico
      vertico-posframe
      consult
      marginalia
      corfu
      orderless

      cape
      # yasnippet

      # toc-org
      # org-super-agenda

      eglot
      poetry
      # nix-mode
      nix-ts-mode
    ]; 
  };
  services.emacs.enable = true; # enable emacs daemon
  services.emacs.defaultEditor = true; 

  home.packages = LSPs;

  home.file.".config/emacs" = {
    source = ./config;
    recursive = true;
  };
}
