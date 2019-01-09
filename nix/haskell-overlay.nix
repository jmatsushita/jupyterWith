_: pkgs:

let
 ihaskellSrc = pkgs.fetchFromGitHub {
      owner = "gibiansky";
      repo = "IHaskell";
      rev = "376d108d1f034f4e9067f8d9e9ef7ddad2cce191";
      sha256 = "0359rn46xaspzh96sspjwklazk4qljdw2xxchlw2jmfa173miq6a";
};
in

{
  haskellPackages = pkgs.haskell.packages.ghc844.override {
    overrides = _: hspkgs:
      let
        callDisplayPackage = name:
          hspkgs.callCabal2nix
            "ihaskell-${name}"
            "${ihaskellSrc}/ihaskell-display/ihaskell-${name}"
            {};
        dontCheck = pkgs.haskell.lib.dontCheck;
      in
      {
        # the current version of hlint in nixpkgs uses a different
        # version of haskell-src-exts, which creates incompatibilities
        # when building ihaskell
        hlint = hspkgs.callHackage "hlint" "2.1.11" {};
        zeromq4-haskell = dontCheck hspkgs.zeromq4-haskell;
        ihaskell          = pkgs.haskell.lib.overrideCabal (
                             hspkgs.callCabal2nix "ihaskell" ihaskellSrc {}) (_drv: {
           preCheck = ''
             export HOME=$(${pkgs.pkgs.coreutils}/bin/mktemp -d)
             export PATH=$PWD/dist/build/ihaskell:$PATH
             export GHC_PACKAGE_PATH=$PWD/dist/package.conf.inplace/:$GHC_PACKAGE_PATH
           '';
           configureFlags = (_drv.configureFlags or []) ++ [
             # otherwise the tests are agonisingly slow and the kernel times out
             "--enable-executable-dynamic"
           ];
           doHaddock = false;
           });
        ghc-parser = hspkgs.callCabal2nix "ghc-parser" "${ihaskellSrc}/ghc-parser" {};
        ipython-kernel = hspkgs.callCabal2nix "ipython-kernel" "${ihaskellSrc}/ipython-kernel" {};
        ihaskell-aeson = callDisplayPackage "aeson";
        ihaskell-blaze = callDisplayPackage "blaze";
        ihaskell-charts = callDisplayPackage "charts";
        ihaskell-diagrams = callDisplayPackage "diagrams";
        ihaskell-gnuplot = callDisplayPackage "gnuplot";
        ihaskell-graphviz = callDisplayPackage "graphviz";
        ihaskell-hatex = callDisplayPackage "hatex";
        ihaskell-juicypixels = callDisplayPackage "juicypixels";
        ihaskell-magic = callDisplayPackage "magic";
        ihaskell-plot = callDisplayPackage "plot";
        ihaskell-rlangqq = callDisplayPackage "rlangqq";
        ihaskell-static-canvas = callDisplayPackage "static-canvas";
        ihaskell-widgets = callDisplayPackage "widgets";
      };
  };
}