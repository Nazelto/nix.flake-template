{ config, pkgs, ... }:
let
  packages = builtins.attrValues ({ inherit (pkgs) python312 uv; });
in
{
  devShells.default = pkgs.mkShell {
    inherit packages;
    shellHook = ''
      echo -e "\033[32m" $(python --version) "\033[0m"
    '';
    env = {
      UV_PYTHON_PREFERENCE = "system";
    };
  };
}
