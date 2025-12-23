{
  description = "flake-utils template";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        systemDeps = [ ];
        hsPkgs = pkgs.haskell.packages.ghc967;
        haskellTools = with hsPkgs; [
          ghc
          haskell-language-server
          hlint
          ormolu
          fourmolu
          cabal-fmt
          hoogle
        ];
        myapp = hsPkgs.callCabal2nix "myapp" ./. { };
      in
      {
        package.default = myapp;
        devShells.default = pkgs.mkShell {
          packages =
            with pkgs;
            [
              nix-info
              # haskell 依赖管理工具
              stack
              cabal-install
            ]
            ++ haskellTools
            ++ systemDeps;
          # 环境变量
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath systemDeps;
          PKG_CONFIG_PATH = "${pkgs.zlib.dev}/lib/pkgconfig";
          shellHook = ''
            echo ""
            echo "══════════════════════════════════════════"
            echo "  🔮 Haskell Development Environment"
            echo "══════════════════════════════════════════"
            echo "  GHC:   $(ghc --numeric-version)"
            echo "  Stack: $(stack --version | head -1)"
            echo "  HLS:   $(haskell-language-server-wrapper --version | head -1)"
            echo "══════════════════════════════════════════"
            echo ""
          '';
        };
      }
    );
}
