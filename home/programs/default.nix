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

  imports = [ spicetify-nix.homeManagerModule ];
  programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
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
  };

  home.packages = with pkgs; [

    brave
    vesktop
    maim 
    xclip
    eza

    feh
    dunst_vol

    lunarvim

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    file
    tree
    acpi
    zathura
    glow
    # gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    # nix-output-monitor

    # process monitoring
    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
  ];
}
