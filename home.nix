{ config, pkgs, ... }:

{
  imports = [
    ./modules/set-fish-shell.nix
  ];

  home = {
    username = "jguerra";
    homeDirectory = "/home/jguerra";
    stateVersion = "25.05"; 

    packages = with pkgs; [
			asdf-vm
			postgresql
      docker
      direnv
      devenv
      cachix
      awscli2
      aws-vault
      lua-language-server
      nodePackages.typescript-language-server
			nodePackages."@astrojs/language-server"
      terraform-ls
      yaml-language-server
      gopls
      nil
      # python311Packages.python-lsp-server  # or use the latest python3 package
    ];

    sessionVariables = {
      DOCKER_HOST = "unix:///var/run/docker.sock";
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      EDITOR = "nvim";
    };

    file = { };
  };

  programs.home-manager.enable = true;

  xdg.configFile."nvim/lua".source = ./nvim-config/lua;

  programs = {
    tmux = {
      enable = true;
    };
    fish = {
      enable = true;
      shellInit = ''
        set -gx PATH /nix/var/nix/profiles/default/bin $HOME/.nix-profile/bin $PATH
				source ${pkgs.asdf-vm}/share/asdf-vm/asdf.fish
      '';
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = builtins.fromTOML (builtins.readFile ./modules/starship/starship.toml);
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
				(nvim-treesitter.withPlugins (p: [
			    p.tree-sitter-typescript
			    p.tree-sitter-tsx
			    p.tree-sitter-javascript
			    p.tree-sitter-json
			    p.tree-sitter-yaml
			    p.tree-sitter-lua
			    p.tree-sitter-bash
			  ]))
        dracula-nvim
        telescope-nvim
        plenary-nvim
        telescope-fzf-native-nvim
        nvim-lspconfig
        cmp-nvim-lsp
        nvim-cmp
				luasnip
				nvim-autopairs
				nvim-ts-autotag
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
