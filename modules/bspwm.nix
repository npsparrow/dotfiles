{ config, lib, pkgs, ...}:
{
  services.xserver = {
    enable = true;
    # autorun = false;
    displayManager.startx.enable = true;
    windowManager.bspwm.enable = true;
    videoDrivers = [ "amdgpu" ];
    xkb = {
      layout = "us";
      # options = "compose:ralt";
    };
    config = ''
      Section "InputClass"
        Identifier "keyboard defaults"
        MatchIsKeyboard "on"
        Option "AutoRepeat" "250 30"
        Option "BellStyle" "none"
      EndSection
    '';
  };
  environment.systemPackages = [ pkgs.sxhkd ];

  services.getty.autologinUser = "nikhil";
  services.libinput = {
    enable = true;
    touchpad = {
      disableWhileTyping = true;
      naturalScrolling = true;
    };
  };

# services.displayManager = {
#   enable = true;
#   defaultSession = "none+bspwm";
#   autoLogin = {
#     enable = true;
#     user = "nikhil";
#   };
#  };
}
