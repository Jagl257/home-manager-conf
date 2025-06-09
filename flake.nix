{
  description = "Home Manager configuration of jguerra";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { nixpkgs, /*home-manager,*/ pre-commit-hooks, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # homeConfigurations."jguerra" = home-manager.lib.homeManagerConfiguration {
      #   inherit pkgs;
      #   modules = [ ./home.nix ];
      # };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.openssl
          pkgs.readline
          pkgs.zlib
          pkgs.bzip2
          pkgs.sqlite
          pkgs.xz
          pkgs.libffi
          pkgs.ncurses
        ];

        shellHook = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            #typos.enable = true;
            statix.enable = true;
          };
        };
      };
    };
}
