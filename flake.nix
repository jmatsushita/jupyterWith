{
  description = "declarative and reproducible Jupyter environments - powered by Nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/a5d03577f0161c8a6e713b928ca44d9b3feb2c37";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , flake-utils
    }:
    (flake-utils.lib.eachSystem ["x86_64-linux"]
      (system:
      let
        pkgs = import nixpkgs
          {
            inherit system;
            overlays = nixpkgs.lib.attrValues self.overlays;
          };
      in
      rec {

        packages = let
          iHaskell = pkgs.jupyterWith.kernels.iHaskellWith {
            extraIHaskellFlags = "--codemirror Haskell"; # for jupyterlab syntax highlighting
            name = "ihaskell-flake";
          };
          iPython = pkgs.jupyterWith.kernels.iPythonWith {
            name = "Python-data-env";
            ignoreCollisions = true;
          };
        in {
          pythonExample = pkgs.jupyterWith.jupyterlabWith {
            kernels = [ iPython ];
          };
          haskellExample = pkgs.jupyterWith.jupyterlabWith {
            kernels = [ iHaskell ];
          };
          hybridExample = pkgs.jupyterWith.jupyterlabWith {
            kernels = [ iHaskell iPython ];
          };
        };

        defaultPackage = self.packages."${system}".pythonExample;

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
        jupyterWith = final: prev: { jupyterWith = prev.callPackage ./. { pkgs = final; }; };
        haskell = import ./nix/haskell-overlay.nix;
        python = import ./nix/python-overlay.nix;
      };
    };
}
