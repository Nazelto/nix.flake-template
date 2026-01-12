{
  description = "Cpp Flake Environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = builtins.attrValues ({
          inherit (pkgs)
            # 编译器
            clang
            clang-tools
            # 构建系统
            xmake
            ninja
            # Debug
            lldb
            ;
        });
      in
      {
        devShells.default = pkgs.mkShell {
          inherit packages;
          shellHook = ''
            if command -v "clang" > /dev/null 2>&1 && command -v "clangd" > /dev/null 2>&1 && command -v "xmake" > /dev/null 2>&1; then 
              echo -e "\033[32m[Success]\033[0m: clang & clangd & Xmake Found!"
              echo -e "\033[32m[Success]\033[0m:" $( clang --version |  head -1)
              echo -e "\033[32m[Success]\033[0m:" $( xmake --version |  head -1)
            else
              echo -e "\033[31m[Error]\033[0m: Cpp Nix Env Not Complate!" 
            fi
          '';
        };
      }
    );
}
