{ config, lib, pkgs, ...}:
{
  services.xserver = {
    enable = true;
    # autorun = false;
    displayManager.startx.enable = true;
    windowManager.bspwm.enable = true;
    videoDrivers = [ "amdgpu" ];
    xkb.layout = "us";
  };
  environment.systemPackages = [ pkgs.sxhkd ];

  services.getty.autologinUser = "nikhil";
  services.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
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
