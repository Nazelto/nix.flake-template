{
  description = "Nix Rust 开发环境";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
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
    {
      self,
      nixpkgs,
      flake-utils,
      fenix,
      crane,
      pre-commit-hooks,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        toolchain = fenix.packages.${system}.stable.toolchain;
        craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;

        # ============================================================
        # 🟢 检测逻辑
        # Nix 只能看到被 git add 的文件，所以这里实际上是在检测
        # "Cargo.toml 是否在 Git 中"
        # ============================================================
        isProjectInitialized = (builtins.pathExists ./Cargo.toml) && (builtins.pathExists ./Cargo.lock);

        # 定义通用参数
        commonArgs = {
          src = craneLib.cleanCargoSource ./.;
          # 你的系统依赖
          buildInputs = [
            # pkgs.openssl
          ];
        };

        # ============================================================
        # 📦 打包逻辑 (惰性求值)
        # 只有在初始化之后，这里才会真正执行
        # ============================================================
        cargoArtifacts = if isProjectInitialized then craneLib.buildDepsOnly commonArgs else null;

        myCrate =
          if isProjectInitialized then
            craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; })
          else
            null;

      in
      {
        # 如果还没初始化，nix build 会提示，而不是报错崩溃
        packages.default =
          if isProjectInitialized then
            myCrate
          else
            pkgs.runCommand "error" { } "echo '请先运行 cargo init 并提交到 git'; exit 1";

        # ============================================================
        # 🐚 开发环境
        # ============================================================
        # 如果项目还没被创建 就没有检查hooks
        checks = {
          # 在进行git提交前进行一系列检查
          pre-commit-checks =
            if isProjectInitialized then

              pre-commit-hooks.lib.${system}.run {
                inherit (commonArgs) src;
                hooks = {
                  #Rust
                  rustfmt.enable = true;
                  clippy.enable = true;
                };
              }
            else
              null;
        };
        devShells.default = pkgs.mkShell {
          # 如果项目已初始化，继承 myCrate 的依赖
          # 如果没初始化，给一个空列表，避免报错
          inputsFrom = if isProjectInitialized then [ myCrate ] else [ ];

          packages = [
            toolchain
            pkgs.git # 方便你在 shell 里 git add
          ];

          shellHook =
            if isProjectInitialized then
              ''
                # pre-commit-hooks
                ${self.checks.${system}.pre-commit-checks.shellHook}
                echo "✅ 检测到 Rust 项目，构建环境已加载 (Crane mode)"
              ''
            else
              ''
                echo "⚠️  未检测到 Cargo.toml 或 Cargo.lock (或者未加入 git)"
                echo "💡 请执行以下步骤初始化:"
                echo "   1. cargo init"
                echo "   2. cargo generate-lockfile"
                echo "   3. git add Cargo.toml Cargo.lock"
                echo "   4. direnv reload (或者退出重进)"
              '';
        };
      }
    );
}
