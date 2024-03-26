{ pkgs, config, ... }: 
{
  imports = [
    ./kitty.nix
    ./starship.nix
  ];
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    autocd = true;


    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };
    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

}
