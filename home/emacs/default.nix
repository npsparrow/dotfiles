{ pkgs, config, ... }:
let
  # LSPs = [
  #   pkgs.clang
  #   pkgs.nil
  #   pkgs.nodePackages.pyright
  # ];
in {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    # query packages with `nix-env -f '<nixpkgs>' -qaP -A emacsPackages`
    extraPackages = epkgs: with epkgs; [
      use-package
      auto-package-update

      which-key
      helpful
      magit
      smartparens
      # exec-path-from-shell
      hl-todo
      undo-tree
      # sudo-edit
      dirvish
      p4

      ligature
      treesit-auto
      treesit-grammars.with-all-grammars
      catppuccin-theme
      solaire-mode
      rainbow-delimiters
      doom-modeline
      nerd-icons
      dashboard
      
      # nerd-icons-dired
      # nerd-icons-ibuffer
      
      # treemacs

      evil
      evil-collection
      evil-surround
      evil-tex

      avy
      vimish-fold

      calfw
      calfw-org

      hydra
      general

      vertico
      vertico-posframe
      consult
      marginalia
      corfu
      orderless

      cape
      yasnippet
      yasnippet-snippets

      # toc-org
      # org-super-agenda

      vterm
      vterm-toggle

      eglot
      meson-mode
      glsl-mode
      just-mode
      justl
      envrc
      # direnv
      haskell-mode
      nix-mode
      zig-mode
      erlang
      rustic
      reformatter
      svelte-mode
      # nix-ts-mode
      auctex
    ]; 
  };
  services.emacs.enable = true; # enable emacs daemon
  services.emacs.defaultEditor = true; 

  home.packages = [pkgs.jdt-language-server];

  home.file.".config/emacs" = {
    source = ./config;
    recursive = true;
  };
}
