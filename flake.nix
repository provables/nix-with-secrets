{
  description = "An extension of writeShellApplication with secrets handling";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    simple-flake.url = "github:waltermoreira/simple-flake";
    shell-utils.url = "github:waltermoreira/shell-utils";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = inputs@{ simple-flake, ... }:
    simple-flake.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { pkgs, inputs', ... }:
        let
          agenix = inputs'.agenix.packages.default;
          appWithSecrets = pkgs.callPackage ./nix/appWithSecrets.nix { inherit agenix; };
          example = import ./secrets-example/example.nix { inherit appWithSecrets; };
          dev = inputs'.shell-utils.lib.shell {
            name = "nix-with-secrets";
            packages = [ agenix example ];
          };
        in
        {
          packages = {
            inherit agenix;
          };
          lib = {
            inherit appWithSecrets;
          };
          packages = {
            inherit agenix;
          };
          devShells = {
            default = dev;
          };
        };
    };
}
