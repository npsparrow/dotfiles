{ config, lib, pkgs, ...}:
{
  # Enable the X11 windowing system.
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
}
