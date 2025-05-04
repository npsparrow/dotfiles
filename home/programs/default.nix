{ config, pkgs, spicetify-nix, ... }:
let
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
  dunst_vol = pkgs.writeScriptBin "dunst_vol" (builtins.readFile ../../scripts/dunst_vol.sh);
in
{
  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Nikhil Panickssery";
    userEmail = "nikhil.panickssery@gmail.com";
    extraConfig.init.defaultBranch = "main";
  };

  imports = [ spicetify-nix.homeManagerModules.default ];
  programs.spicetify =
    let spicePkgs = spicetify-nix.legacyPackages.${pkgs.system}; in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        hidePodcasts
        keyboardShortcut
      ];
    };

  programs.zathura = {
    enable = true;
    # SET UP SYNCTEX
    # options = {
    #   synctex = "true";
    #   synctex-editor-command = "emacsclient +%{line} +%{input}";
    # };
    mappings = {
      "<C-i>" = "recolor";
    };
    options = {
      show-recent = 0;
      selection-clipboard = "clipboard";
      selection-notification = false;
    };
  };

  home.packages = [

    pkgs.pkgsCross.armv7l-hf-multiplatform.glibc

    pkgs.brave
    pkgs.vesktop
    # (pkgs.discord.override {
    #   # remove any overrides that you don't want
    #   withOpenASAR = true;
    #   withVencord = true;
    # })
    pkgs.maim 
    pkgs.xclip
    pkgs.eza
    pkgs.just
    pkgs.cachix
    pkgs.webex
    pkgs.zoom-us
    pkgs.docker-compose
    pkgs.libreoffice

    pkgs.p4

    pkgs.jetbrains.idea-community
    pkgs.jdk8

    # pkgs.ghidra
    pkgs.ida-free

    pkgs.prismlauncher
    pkgs.ferium
    pkgs.desmume
    pkgs.libfaketime

    # pkgs.lime3ds
    pkgs.appimage-run

    pkgs.texlive.combined.scheme-full

    pkgs.feh
    dunst_vol

    pkgs.lunarvim

    # archives
    pkgs.zip
    pkgs.xz
    pkgs.unzip
    pkgs.p7zip

    # utils
    pkgs.ripgrep # recursively searches directories for a regex pattern
    pkgs.jq # A lightweight and flexible command-line JSON processor
    pkgs.yq-go # yaml processor https://github.com/mikefarah/yq
    pkgs.eza # A modern replacement for ‘ls’
    pkgs.fzf # A command-line fuzzy finder
    pkgs.tldr

    # networking tools
    pkgs.mtr # A network diagnostic tool
    pkgs.iperf3
    pkgs.dnsutils  # `dig` + `nslookup`
    pkgs.ldns # replacement of `dig`, it provide the command `drill`
    pkgs.aria2 # A lightweight multi-protocol & multi-source command-line download utility
    pkgs.socat # replacement of openbsd-netcat
    pkgs.nmap # A utility for network discovery and security auditing
    pkgs.ipcalc  # it is a calculator for the IPv4/v6 addresses
    pkgs.tcpdump

    # misc
    pkgs.file
    pkgs.tree
    pkgs.acpi
    pkgs.glow
    # gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    # nix-output-monitor

    # process monitoring
    pkgs.btop  # replacement of htop/nmon
    pkgs.iotop # io monitoring
    pkgs.iftop # network monitoring

    # system call monitoring
    pkgs.strace # system call monitoring
    pkgs.ltrace # library call monitoring
    pkgs.lsof # list open files

    # system tools
    pkgs.sysstat
    pkgs.lm_sensors # for `sensors` command
    pkgs.ethtool
    pkgs.pciutils # lspci
    pkgs.usbutils # lsusb
  ];
}
