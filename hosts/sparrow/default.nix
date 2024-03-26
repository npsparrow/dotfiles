# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# look at system.autoUpgrade / do nixos-rebuild switch --upgrade

{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ../../modules/system.nix
      ../../modules/bspwm.nix
      ./hardware-configuration.nix
    ];

  
  # ???
  environment.variables.STEAM_API_KEY = "7EDE7F4E57DB19E978AD9B05FC00A412";


  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # ==============

  boot = {
    consoleLogLevel = 0;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
      systemd-boot.configurationLimit = 10;
    };
  };

  
  networking.hostName = "sparrow"; 	# Define your hostname.
  age.secrets.rpi_pass.file = ../secrets/rpi_pass.age;
  networking.wireless = {
    enable = true;  			# Enables wireless support via wpa_supplicant.
    userControlled.enable = true; 	# Enables support for wpa_cli and wpa_gui
    networks = {
      # "Andromeda".pskRaw = "2cf19bae44e4982c910947e054825495a8c52220307e75bb9604f0e2db4d8ec7";
      "peregrine".pskRaw = "1a7de5f5721757ba5a3b8252c96b5fea9eb59705bf5ffc11d0cc5754594055ea";
      "rpi_wpa2" = {
        auth = ''
          key_mgmt=WPA-EAP
          eap=PEAP
          phase2="auth=MSCHAPV2"
          identity="panicn"
          password="$(cat "${config.age.secrets.rpi_pass.path}")"
        '';
      };
    };
  };

  # Enable the X11 windowing system.
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = [ pkgs.mesa.drivers ];
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];

    windowManager.bspwm.enable = true;

    xkb.layout = "us";
    libinput.enable = true;
    displayManager.defaultSession = "none+bspwm";
    displayManager.autoLogin = {
      enable = true;
      user = "nikhil";
    };
  };

  
  services.autorandr = {
    enable = true;
    defaultTarget = "laptop";
    profiles = {
      "laptop" = {
        fingerprint = {
          eDP = "00ffffffffffff004d102c1500000000311e0104a522137807de50a3544c99260f5054000000010101010101010101010101010101011534805070381f401810350058c210000018000000fd0e3c2d4f4f43010a202020202020000000100000000000000000000000000000000000fc004c513135364d314a5732350a2001f37013790000030114650401847f074f0017000f0037041e000200040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001490";
        };
        config = {
          eDP = {
            enable = true;
            primary = true;
            mode = "1920x1080";
            rate = "300.00";
          };
        };
      };

      "dual" = {
        fingerprint = {
          DisplayPort-1-0 = "00ffffffffffff0006b3a825010101010921010380361e78ea0875a6574ea3260c5054b7ef0081c081cf8100810fd1c0d1d9d1e8d1fc023a801871382d40582c4500202f2100001e000000fd0030f01eff3c000a202020202020000000fc005647323539514d0a2020202020000000ff0052334c4d51533031393735320a01c8020346f1519001020311123f6013040e0f1d1e1f4061230907078301000067030c001000382e68d85dc40178800002681a0000010030f0e6e305df01e6060701606000e2006a866f80a07038404030203500202f2100001a23e88078703887402020980c202f2100001afc7e80887038124018203500202f2100001e000000f2";
          eDP = "00ffffffffffff004d102c1500000000311e0104a522137807de50a3544c99260f5054000000010101010101010101010101010101011534805070381f401810350058c210000018000000fd0e3c2d4f4f43010a202020202020000000100000000000000000000000000000000000fc004c513135364d314a5732350a2001f37013790000030114650401847f074f0017000f0037041e000200040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001490";
        };
        config = {
          DisplayPort-1-0 = {
            enable = true;
            primary = true;
            position = "0x1080";
            mode = "1920x1080";
            rate = "240.00";
          };
          eDP = {
            enable = true;
            primary = false;
            position = "0x0";
            mode = "1920x1080";
            rate = "300.00";
          };
        };
      };
    };
  };
  # services.udev.extraRules = ''ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.autorandr}/bin/autorandr -c"''; 


  age.secrets.vcvol.file = ../secrets/vcvol.age;
  systemd.services.veradecrypt = {
    description = "Decrypt veracrypt partition";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      DefaultDependencies = "no"; # avoid ordering cycle
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = ''${pkgs.bash}/bin/bash -c "cat '${config.age.secrets.vcvol.path}' | ${pkgs.cryptsetup}/bin/cryptsetup --type=tcrypt --veracrypt open /dev/nvme0n1p2 additional"'';
      ExecStop = "${pkgs.cryptsetup}/bin/cryptsetup close /dev/mapper/additional";
    };
  };

  systemd.mounts = [{
    description = "Mount veracrypt partition";
    wantedBy = [ "multi-user.target" ];
    after = ["veradecrypt.service"];
    requires = ["veradecrypt.service"];
    bindsTo = ["veradecrypt.service"];
    unitConfig = {
      DefaultDependencies = "no"; # avoid ordering cycle
    };
    what = "/dev/mapper/additional";
    where = "/mnt/additional";
    type = "ntfs-3g";
    options = "rw,uid=1000,gid=100,umask=0077";
  }];

  services.openssh = {
    enable = true;
    settings = {
      # X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    # openFirewall = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };


  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

