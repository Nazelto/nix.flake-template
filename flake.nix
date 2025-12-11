{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

  };

  outputs =
    { self, nixpkgs, ... }:
    {
      templates = {
        default = {
          description = "flake-utils template";
          path = "./template/flake-utils";
        };
      };

    };
}
