{ config, lib, pkgs, ...}:
{
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    windowManager.bspwm.enable = true;
    xkb.layout = "us";
  };

  services.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
  };

  services.displayManager = {
    enable = true;
    defaultSession = "none+bspwm";
    autoLogin = {
      enable = true;
      user = "nikhil";
    };
  };
}
