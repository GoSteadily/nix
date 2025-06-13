{
  description = "Nix resources for working on Steadily's projects.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    rnix-lsp = {
      url = "github:nix-community/rnix-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , rnix-lsp
    , ...
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; };

        mosh = pkgs.callPackage ./packages/mosh { };
        neovim = pkgs.callPackage ./packages/neovim { };
        ranger = pkgs.callPackage ./packages/ranger { };
        screen = pkgs.callPackage ./packages/screen { };
        tmux = pkgs.callPackage ./packages/tmux { };
      in
      {
        packages = {
          rnix-lsp = rnix-lsp.defaultPackage.${system};
          inherit mosh neovim ranger screen tmux;
        };

        devShells.default = pkgs.mkShell {
          packages = [ ];

          shellHook = ''
            # Load ~/.bashrc if it exists
            test -f ~/.bashrc && source ~/.bashrc

            # Initialize $PROJECT environment variable
            export PROJECT="$PWD"

            # Source .env file if present
            test -f "$PROJECT/.env" && source .env
          '';
        };
      }
      ) //
    {
      nixosModules = {
        default = {
          imports = [
            self.nixosModules.apps
            self.nixosModules.redirects
            self.nixosModules.secrets
            self.nixosModules.user
            self.nixosModules.volumes
          ];
        };

        apps = import ./modules/apps.nix;
        redirects = import ./modules/redirects.nix;
        secrets = import ./modules/secrets.nix;
        user = import ./modules/user.nix;
        volumes = import ./modules/volumes.nix;
        digitalOcean = import ./modules/virtualisation/digital-ocean.nix;
      };
    };
}
