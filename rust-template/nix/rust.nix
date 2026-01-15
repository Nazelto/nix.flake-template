{
  config,
  pkgs,
  toolchain,
  crane,
  pname ? "rust-app",
  version ? "0.1.0",
  ...
}:

let
  craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;

  commonArgs = {
    src = craneLib.cleanCargoSource ./.;
    buildInputs = [ ];
    inherit pname version;
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;

  packages = craneLib.buildPackage (
    commonArgs
    // {
      inherit cargoArtifacts;
    }
  );

in
{
  # 暴露给其他模块使用
  inherit commonArgs packages craneLib;
}
