{
  description = "Nix Rust 开发环境 (flake-parts 模块化版本)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane = {
      url = "github:ipetkov/crane";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          # ============================================================
          # 🔧 基础工具链
          # ============================================================
          toolchain = inputs.fenix.packages.${system}.stable.toolchain;

          # ============================================================
          # 🟢 检测逻辑
          # ============================================================
          isProjectInitialized = (builtins.pathExists ./Cargo.toml) && (builtins.pathExists ./Cargo.lock);

          # ============================================================
          # 🦀 Rust 构建配置（原 args.nix）
          # ============================================================
          rustConfig =
            if isProjectInitialized then
              import ./nix/rust.nix {
                inherit config pkgs toolchain;
                crane = inputs.crane;
              }
            else
              null;

        in
        {
          # ============================================================
          # 📤 向所有模块传递参数
          # ============================================================
          _module.args = {
            inherit
              toolchain
              isProjectInitialized
              rustConfig
              ;
          };

          # ============================================================
          # 📥 导入模块
          # ============================================================
          imports = [
            ./nix/packages.nix
            ./nix/devshells.nix
            ./nix/checks.nix
          ];
        };
    };
}
