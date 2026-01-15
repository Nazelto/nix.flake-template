{
  config,
  self',
  pkgs,
  toolchain,
  isProjectInitialized,
  rustConfig,
  ...
}:

{
  devShells.default = pkgs.mkShell {
    # 如果项目已初始化，继承构建依赖
    inputsFrom = if isProjectInitialized then [ rustConfig.packages ] else [ ];

    packages = [
      toolchain
      pkgs.git
      #pkgs.cargo-edit # 可选：cargo add/rm/upgrade
      #pkgs.cargo-watch # 可选：cargo watch
    ];

    shellHook =
      if isProjectInitialized then
        ''
          # pre-commit-hooks
          ${config.checks.pre-commit-checks.shellHook or ""}

          echo ""
          echo "✅ Rust 开发环境已加载"
          echo "🦀 Toolchain: $(rustc --version)"
          echo "📦 Crane: enabled"
          echo ""
        ''
      else
        ''
          echo ""
          echo "⚠️  未检测到 Cargo.toml 或 Cargo.lock"
          echo ""
          echo "💡 请执行以下步骤初始化项目:"
          echo "   1. cargo init"
          echo "   2. cargo generate-lockfile"
          echo "   3. git add Cargo.toml Cargo.lock"
          echo "   4. direnv reload (或退出重进)"
          echo ""
        '';
  };
}
