{
  description = "Home Manager configuration of jguerra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, home-manager, pre-commit-hooks, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    homeConfigurations."jguerra" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home.nix
        {
          home.username = "jguerra";
          home.homeDirectory = "/home/jguerra";
          home.stateVersion = "25.05";
        }
      ];
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [ openssl openssl.dev readline zlib bzip2 sqlite xz libffi ncurses ];
      shellHook = ''
        export CPPFLAGS="-I${pkgs.openssl.dev}/include"
        export LDFLAGS="-L${pkgs.openssl.out}/lib"
        export LD_LIBRARY_PATH="${pkgs.openssl.out}/lib:$LD_LIBRARY_PATH"
      '' + (pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
      });
    };
  };
}

