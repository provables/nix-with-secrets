{ appWithSecrets, ... }:

appWithSecrets {
  name = "example";
  secrets = [ "secret1.age" "secret2.age" ];
  secretsDir = ./.;
  identity = ./aUser;
  text = ''
    ls "$SECRETS_DIR"
    echo "secret1:"
    cat "$SECRETS_DIR"/secret1.age
    echo "secret2:"
    cat "$SECRETS_DIR"/secret2.age
  '';
}
