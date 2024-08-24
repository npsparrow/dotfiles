# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# look at system.autoUpgrade / do nixos-rebuild switch --upgrade

{ config, lib, pkgs, ... }:
let
  additional_byid = "/dev/disk/by-id/nvme-eui.002538bb11419984-part2";

  eDP_id = "00ffffffffffff004d102c1500000000311e0104a522137807de50a3544c99260f5054000000010101010101010101010101010101011534805070381f401810350058c210000018000000fd0e3c2d4f4f43010a202020202020000000100000000000000000000000000000000000fc004c513135364d314a5732350a2001f37013790000030114650401847f074f0017000f0037041e000200040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001490";

  DisplayPort_id = "00ffffffffffff0006b3a825010101010921010380361e78ea0875a6574ea3260c5054b7ef0081c081cf8100810fd1c0d1d9d1e8d1fc023a801871382d40582c4500202f2100001e000000fd0030f01eff3c000a202020202020000000fc005647323539514d0a2020202020000000ff0052334c4d51533031393735320a01c8020346f1519001020311123f6013040e0f1d1e1f4061230907078301000067030c001000382e68d85dc40178800002681a0000010030f0e6e305df01e6060701606000e2006a866f80a07038404030203500202f2100001a23e88078703887402020980c202f2100001afc7e80887038124018203500202f2100001e000000f2";
in
{
  imports =
    [ 
      ../../modules/system.nix
      ../../modules/bspwm.nix
      ./hardware-configuration.nix
    ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  boot = {
    consoleLogLevel = 0;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
      systemd-boot.configurationLimit = 10;
    };
  };

  
  networking.hostName = "sparrow";
  age.secrets.wireless.file = ../../secrets/wireless.age;
  networking.wireless.environmentFile = "${config.age.secrets.wireless.path}";
  networking.wireless = {
    enable = true;  			          # Enables wireless support via wpa_supplicant.
    userControlled.enable = true; 	# Enables support for wpa_cli and wpa_gui
    networks = {
      "peregrine".pskRaw = "@PSK_PEREGRINE@";
      "enkay".pskRaw = "@PSK_HOME@";
      "rpi_wpa2" = {
        auth = ''
          key_mgmt=WPA-EAP
          eap=PEAP
          phase2="auth=MSCHAPV2"
          identity="@RPI_IDENTITY@"
          password="@RPI_PASSWORD@"
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
    libinput.touchpad.disableWhileTyping = true;
    displayManager.defaultSession = "none+bspwm";
    displayManager.autoLogin = {
      enable = true;
      user = "nikhil";
    };
  };

  
  # enable autorandr and hotplug
  services.autorandr = {
    enable = true;
    defaultTarget = "laptop";
    profiles = {
      "laptop" = {
        fingerprint = {
          eDP = "${eDP_id}";
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
          DisplayPort-1-0 = "${DisplayPort_id}";
          eDP = "${eDP_id}";
        };
        config = {
          DisplayPort-1-0 = {
            enable = true;
            primary = true;
            position = "1920x0";
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
  services.udev.extraRules = ''ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.autorandr}/bin/autorandr -c"''; 

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };


  age.secrets.vcvol.file = ../../secrets/vcvol.age;
  systemd.services.veradecrypt = {
    description = "Decrypt veracrypt partition";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      DefaultDependencies = "no"; # avoid ordering cycle
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = ''${pkgs.bash}/bin/bash -c "cat '${config.age.secrets.vcvol.path}' | ${pkgs.cryptsetup}/bin/cryptsetup --type=tcrypt --veracrypt open ${additional_byid} additional"'';
      ExecStop = "${pkgs.cryptsetup}/bin/cryptsetup close /dev/mapper/additional";
    };
  };

  systemd.mounts = [{
    description = "Mount veracrypt partition";
    wantedBy = [ "multi-user.target" ];
    after = ["veradecrypt.service"]; # which of these three things matters?
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


  # For more information, see `man configuration.nix` or
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11";

}

