{config, lib, ...}:
{
  home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = lib.concatStrings [
        # "$username$hostname" 
        "$directory"
        "$git_branch"
        "$rust"
        "[|](bold white) $battery"
        "[|](bold white) $time"
        "\n"
        "$character"
      ];
      add_newline = false;
      battery = {
        disabled = false;
        display = [
          {
            threshold = 25;
            style = "bold red";
          }
          {
            threshold = 75;
            style = "bold yellow";
          }
          {
            threshold = 100;
            style = "bold green";
          }
        ];
      };
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      username = {
        # show_always = true;
        # style_root = "bold red";
      };
      time = {
        disabled = false;
      };
      # nix_shell = {
      #   disabled = false;
      #   heuristic = true;
      # };
    };
  };
}
