{ config, pkgs, ... }:

{
  home.username = "jguerra";
  home.homeDirectory = "/home/jguerra";
  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    docker
    direnv
    devenv
    cachix
    awscli2
    aws-vault
    lua-language-server
    nodePackages.typescript-language-server
    terraform-ls
    yaml-language-server
    gopls
    # python311Packages.python-lsp-server  # or use the latest python3 package
  ];

  home.sessionVariables = {
    DOCKER_HOST = "unix:///var/run/docker.sock";
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
    EDITOR = "nvim";
  };

  home.file = {};

  programs.home-manager.enable = true;
  xdg.configFile."nvim/lua".source = ./nvim-config/lua;

  programs = {
    tmux = {
      enable = true;
      shell = "${pkgs.bash}/bin/fish";
    };
    fish = {
      enable = true;
      shellInit = ''
        set -gx ASDF_DIR $HOME/.asdf
        source $ASDF_DIR/asdf.fish
        starship init fish | source
      '';
    };
    starship = {
      enable = true;
      settings = {
        shell = {
          disabled = false;
          format = "[$indicator]($style) ";
          bash_indicator = "Bash";
          zsh_indicator = "Zsh";
          fish_indicator = "Fish";
          style = "bold green";
        };
        nodejs = {
          format = "via [⬢ $version](bold green) ";
        };
        python = {
          format = "via [🐍 $version](bold blue) ";
          detect_extensions = [ "py" ];
        };
        nix_shell = {
          disabled = false;
          format = "via [$symbol$state( $name)]($style) ";
          symbol = "❄️ ";
          style = "bold blue";
        };
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
        };
        format = "$directory $nix_shell $git_branch $nodejs $python $character";
      };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        dracula-nvim
        telescope-nvim
        plenary-nvim
        telescope-fzf-native-nvim
        nvim-lspconfig
        cmp-nvim-lsp
        nvim-cmp
        CopilotChat-nvim
      ];
      extraPackages = with pkgs; [
        xclip
      ];
      extraLuaConfig = builtins.readFile ./nvim-config/init.lua;
    };
    git = {
      enable = true;
      userName = "Jorge Guerra";
      userEmail = "jagl257@gmail.com";
      aliases = {
        co = "checkout";
      };
    };
  };
}
