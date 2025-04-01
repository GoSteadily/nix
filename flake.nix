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
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        mosh = pkgs.callPackage ./lib/packages/mosh {};
        neovim = pkgs.callPackage ./lib/packages/neovim {};
        ranger = pkgs.callPackage ./lib/packages/ranger {};
        screen = pkgs.callPackage ./lib/packages/screen {};
        tmux = pkgs.callPackage ./lib/packages/tmux {};
      in
      {
        packages = {
          rnix-lsp = rnix-lsp.defaultPackage.${system};
          inherit mosh neovim ranger screen tmux;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            neovim
            pkgs.fzf
            pkgs.silver-searcher
            ranger
            self.packages.${system}.rnix-lsp
          ];

          shellHook = ''
            # Load ~/.bashrc if it exists
            test -f ~/.bashrc && source ~/.bashrc

            # Initialize $PROJECT environment variable
            export PROJECT="$PWD"

            # Source .env file if present
            test -f "$PROJECT/.env" && source .env

            # Ignore files specified in .gitignore when using fzf
            # -t only searches text files and includes empty files
            export FZF_DEFAULT_COMMAND="ag -tl"
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
            self.nixosModules.digitalOcean
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
