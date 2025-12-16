#TODO: 更新为flake part
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        templates = {
          default = {
            description = "flake-utils template";
            path = ./flake-utils-template;
          };
          flake-parts = {
            description = "flake-parts-template";
            path = ./flake-parts-template;
          };
        };
      };
    };
}
