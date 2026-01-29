{
  config,
  pkgs,
  ...
}:
let
  packages = builtins.attrValues ({
    inherit (pkgs)
      #编译器
      go
      #formatter
      gofumpt
      gotools
      go-tools
      #Linter
      golangci-lint
      ;
  });
in
{
  devShells.default = pkgs.mkShell {
    inherit packages;
    shellHook = ''
      echo -e $(go version)
    '';
  };
}
