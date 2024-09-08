{ pkgs, lib, ... }: 
let
  username = "nikhil";
in {
  # ============================= User related =============================

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nikhil = {
    isNormalUser = true;
    useDefaultShell = true;
    description = "nikhil";
    extraGroups = [ "wheel" "docker" "video" ];
  };

  nix.registry.sparrow.to = {
    owner = "npsparrow";
    repo = "flake_templates";
    type = "github";
  };


  # customise /etc/nix/nix.conf declaratively via `nix.settings`
  nix.settings.trusted-users = [username];
  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    builders-use-substitutes = true;
    auto-optimise-store = true;
  };

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set the time zone.
  time.timeZone = "America/New_York";
  time.hardwareClockInLocalTime = true; 

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Install docker.
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons
      material-icons
      material-symbols
      icomoon-feather

      # normal fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      # polybar default font
      siji

      # nerdfonts
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Lilex" ]; })
    ];

    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = {
      serif = ["Noto Serif" "Noto Color Emoji"];
      sansSerif = ["Noto Sans" "Noto Color Emoji"];
      monospace = ["Lilex Nerd Font" "Noto Color Emoji"];
      emoji = ["Noto Color Emoji"];
    };
  };

  programs.dconf.enable = true;

  networking.firewall.enable = true;

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim 
    devenv
    wget
    curl
    git
    sysstat
    lm_sensors # for `sensors` command
    xfce.thunar # xfce4's file manager
    nnn # terminal file manager
    sbctl
    ntfs3g
    man-pages
    man-pages-posix
  ];
  documentation.dev.enable = true;

  # sound.enable = false;               # ALSA; NO LONGER HAS ANY EFFECT
  hardware.pulseaudio.enable = false; # pulseaudio

  services.power-profiles-daemon.enable = true;

  security.polkit.enable = true;

  services = {
    # dbus.packages = [pkgs.gcr];
    # geoclue2.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      # media-session.enable = true;
    };

    # udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  };
}
