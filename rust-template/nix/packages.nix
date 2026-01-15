{
  config,
  pkgs,
  isProjectInitialized,
  rustConfig,
  ...
}:

{
  packages.default =
    if isProjectInitialized then
      rustConfig.packages
    else
      pkgs.runCommand "rust-project-not-initialized" { } ''
        echo ""
        echo "❌ Rust 项目尚未初始化"
        echo ""
        echo "💡 请执行以下步骤:"
        echo "   1. cargo init"
        echo "   2. cargo generate-lockfile"
        echo "   3. git add Cargo.toml Cargo.lock"
        echo "   4. direnv reload"
        echo ""
        exit 1
      '';
}
