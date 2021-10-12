{
  description = "declarative and reproducible Jupyter environments - powered by Nix";

  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = github:/teto/flake-compat/support-packages;
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs/a5d03577f0161c8a6e713b928ca44d9b3feb2c37";
    ihaskell.url = github:teto/IHaskell/forJupyter;
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , ihaskell
    , flake-utils
    , ...
    }:
    (flake-utils.lib.eachSystem ["x86_64-linux"]
      (system:
      let
        pkgs = import nixpkgs
          {
            inherit system;
            overlays = nixpkgs.lib.attrValues self.overlays;
              # [ self.overlays.jupyterWith ];
          };
      in
      rec {

        packages = let
          iHaskellEnv = pkgs.jupyterWith.kernels.iHaskellWith {
            name = "ihaskell-flake";
            packages = p: with p; [ vector aeson ];
            extraIHaskellFlags = "--codemirror Haskell"; # for jupyterlab syntax highlighting
            haskellPackages = pkgs.haskellPackages;
          };
        in
        {
          ihaskell = pkgs.jupyterWith.jupyterlabWith {
            kernels = [ iHaskellEnv ];
            # directory = "./.jupyterlab";
          };
        };

        defaultPackage = self.packages."${system}".ihaskell;

        lib = {
          inherit (pkgs.jupyterWith)
            jupyterlabWith
            kernels
            mkBuildExtension
            mkDirectoryWith
            mkDirectoryFromLockFile
            mkDockerImage
            ;
        };
      }
      )
    ) //
    {
      overlays = {
        jupyterWith = final: prev: {
          jupyterWith = prev.callPackage ./. { pkgs = final; };
        };
        # haskell = import ./nix/haskell-overlay.nix;
        haskell = ihaskell.overlay;
        python = import ./nix/python-overlay.nix;
      };
    };
}
