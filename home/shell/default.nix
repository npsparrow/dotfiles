# CONTAINS:
# terminal utilities
# - bat
# - direnv
# - ranger
# zsh
# env vars

{ pkgs, config, ... }: 
{
  imports = [
    ./kitty.nix
    ./starship.nix
  ];
  programs = {

    # ========================
    # TERMINAL UTILITIES
    # ========================

    bat = {
      enable = true;
      config.theme = "catppuccin-mocha";
      themes = {
        catppuccin-mocha = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "b19bea35a85a32294ac4732cad5b0dc6495bed32";
            sha256 = "POoW2sEM6jiymbb+W/9DKIjDM1Buu1HAmrNP0yC2JPg=";
          };
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    ranger.enable = true;

    zoxide.enable = true;
    
    # ========================
    # ZSH
    # ========================

    zsh = {
      enable = true;
      dotDir = ".config/zsh";

      syntaxHighlighting.enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      autocd = true;

      profileExtra = ''
if [[ -z "$DISPLAY" ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec startx
fi
'';
      shellAliases = {
        l = "eza --icons -F -H --group-directories-first --git -1 -alF";
        ls = "eza --icons -F -H --group-directories-first --git -1 -alF";
        update = "sudo nixos-rebuild switch";
      };
      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "";
      };
    };
  };

  # ========================
  # ENV VARS
  # ========================

  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    STEAM_API_KEY = "7EDE7F4E57DB19E978AD9B05FC00A412";
    LESSHISTFILE = "-";
    PYTHON_HISTORY = "$HOME/.local/share/python/history";

    # use bat for manpager
    # catppuccin is broken for manpages (see #2115)
    # https://github.com/sharkdp/bat/issues/2115
    MANPAGER="sh -c 'col -bx | bat --theme=default -l man -p'";
    MANROFFOPT="-c";
  };

}
