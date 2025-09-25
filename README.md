# Nix With Secrets

A simple wrapper for `writeShellApplication` for using [`agenix`](https://github.com/ryantm/agenix) to provide secrets to
an application.

Play with the example app by running `nix develop` and then executing `example`.

The function `appWithSecrets` extends the commands of `writeShellApplication` to include:

- `secretsDir`: a directory with a file `secrets.nix` as required by `agenix`.
- `secrets`: a list of secrets to make available to the application.
- `identity`: an optional identity (useful for testing, as in the `example` app).
  Leave this option empty to use the default behavior, which searches the public keys
  for the user in the usual `$HOME/.ssh`.

The secrets are available to the app in a directory specified in the environment
variable `SECRETS_DIR`. The directory is deleted on exit, or on error.

## License

MIT