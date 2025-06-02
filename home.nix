{config,pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jguerra";
  home.homeDirectory = "/Users/jguerra";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
		pkgs.go
		pkgs.docker
		pkgs.direnv
		pkgs.devenv
		pkgs.cachix
		pkgs.awscli2
		pkgs.aws-vault
		pkgs.lua-language-server
		pkgs.nodePackages.typescript-language-server
		pkgs.terraform-ls
		pkgs.yaml-language-server
		pkgs.gopls
		pkgs.python311Packages.python-lsp-server  # or use the latest python3 package
  ];

	home.sessionVariables = {
    DOCKER_HOST = "unix:///var/run/docker.sock";
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jguerra/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  xdg.configFile."nvim/lua".source = ./nvim-config/lua;

	programs = {
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
