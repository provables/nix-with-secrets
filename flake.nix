{
  description = "An extension of writeShellApplication with secrets handling";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    shell-utils.url = "github:waltermoreira/shell-utils";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = inputs:
    with inputs.flake-utils.lib; eachDefaultSystem
      (system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          shell = inputs.shell-utils.myShell.${system};
          agenix = inputs.agenix.packages.${system}.default;
          # Extend `writeShellApplication` to use agenix for decrypting secrets
          # and mounting them in the directory `$SECRETS_DIR`. The directory is 
          # deleted on exit, or on errors.
          # - `secrets` is a list of strings indicating which secrets to mount for this
          #   app.
          # - `secretsDir` is the path containing `secrets.nix` and the encrypted .age
          #   files.
          # - `identity` is the runtime location of the private key (defaults to 
          #   searching the $HOME/.ssh). Mostly useful for testing. Recommended to
          #   leave this option as the default.
          appWithSecrets =
            args@{ secrets
            , secretsDir
            , identity ? null
            , runtimeInputs ? [ ]
            , text ? ""
            , ...
            }:
            let
              newArgs = builtins.removeAttrs args [
                "secrets"
                "secretsDir"
                "identity"
                "text"
                "runtimeInputs"
              ];
              runtimeInputsArg = runtimeInputs ++ [ agenix ];
              identityArg = if builtins.isNull identity then "" else "-i ${identity}";
              textArg = ''
                onerror () {
                  rm -rf "$1"
                }
                onexit () {
                  rm -rf "$1"
                }
                mount_secrets () {
                  (
                    cd ${secretsDir}
                    T=$(mktemp -d)
                    ${
                      builtins.concatStringsSep "\n"
                        (builtins.map 
                          (x: ''agenix -d ${x} ${identityArg} > "$T"/${x}'') secrets)
                    }
                    echo "$T"
                  )
                }
                SECRETS_DIR="$(mount_secrets)"
                export SECRETS_DIR
                trap 'onerror "$SECRETS_DIR"' ERR
                trap 'onexit "$SECRETS_DIR"' EXIT
                ${text}
              '';
            in
            pkgs.writeShellApplication ({
              runtimeInputs = runtimeInputsArg;
              text = textArg;
            } // newArgs);
          example = appWithSecrets {
            name = "example";
            secrets = [ "secret1.age" "secret2.age" ];
            secretsDir = ./secrets-example;
            identity = ./secrets-example/aUser;
            text = ''
              ls "$SECRETS_DIR"
              echo "secret1:"
              cat "$SECRETS_DIR"/secret1.age
              echo "secret2:"
              cat "$SECRETS_DIR"/secret2.age
            '';
          };
          dev = shell {
            name = "nix-with-secrets";
            packages = [ agenix example ];
          };
        in
        {
          lib = {
            inherit appWithSecrets;
          };
          devShells = {
            default = dev;
          };
        });
}
