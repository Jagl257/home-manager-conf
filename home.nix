{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/set-fish-shell.nix
		./modules/claude/claude.nix
  ];

  home = {
    username = "jagl257";
    homeDirectory = "/home/jagl257";
    stateVersion = "25.05";
    enableNixpkgsReleaseCheck = false; 

    packages = with pkgs; [
			nerd-fonts.jetbrains-mono
			asdf-vm
			postgresql
      docker
      direnv
      devenv
      cachix
      awscli2
      aws-vault
      lua-language-server
      typescript-language-server
      terraform-ls
      yaml-language-server
      gopls
      nil
      # python311Packages.python-lsp-server  # or use the latest python3 package

      # xdg-open wrapper for WSL - forwards to wslview to open URLs in Windows browser
      (writeShellScriptBin "xdg-open" ''
        #!/usr/bin/env bash
        # WSL xdg-open wrapper that forwards to wslview
        # This makes Linux applications (like GitLab MCP) open URLs in Windows browser

        if [ $# -eq 0 ]; then
          echo "Usage: xdg-open <url|file>" >&2
          exit 1
        fi

        # Forward all arguments to wslview
        exec /usr/bin/wslview "$@"
      '')
    ];

    sessionVariables = {
      DOCKER_HOST = "unix:///var/run/docker.sock";
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      EDITOR = "nvim";
    };

    file = { };
  };
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "claude-code"
  ];

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
        set -gx BROWSER \"wslview\"
        fish_add_path $HOME/.asdf/shims
      '';
      shellAliases = {
        # Git aliases
        gst = "git status";
        gad = "git add";
        gcm = "git commit -m";
        gca = "git commit --amend";
        glg = "git log --oneline";
        gco = "git checkout";
        gcb = "git checkout -b";
        # Tmux alias
        tmx = "tmux";
        gaa = "git add .";
        gcam = "git commit -am";
        gp = "git pull";
        gpu = "git push";
        gpf = "git push --force";
        grb = "git rebase";
        gre = "git reset";
        grh = "git reset --hard";
        glo = "git log --oneline";
        grl = "git reflog";
        gd = "git diff";
        gb = "git branch";
        tmxn = "tmux new -s";
        tmxa = "tmux attach";
      };
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
				tokyonight-nvim
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
				neo-tree-nvim
				nui-nvim
				nvim-web-devicons
      ];
      extraPackages = with pkgs; [
        xclip
      ];
      initLua = builtins.readFile ./nvim-config/init.lua;
      withRuby = true;
      withPython3 = true;
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "Jorge Guerra";
          email = "jagl257@gmail.com";
        };

      };
    };
  };
}
