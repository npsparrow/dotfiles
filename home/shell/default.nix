{ pkgs, config, ... }: 
{
  imports = [
    ./kitty.nix
    ./starship.nix
  ];
  programs = {

    direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    zsh = {
      enable = true;
      dotDir = ".config/zsh";

      syntaxHighlighting.enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      autocd = true;

      shellAliases = {
        l = "eza --icons -F -H --group-directories-first --git -1 -alF";
        ls = "eza --icons -F -H --group-directories-first --git -1 -alF";
        update = "sudo nixos-rebuild switch";
      };
      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      oh-my-zsh = {
        enable = true;
        plugins = [ "direnv" "git" ];
        theme = "";
      };
    };
  };

}
