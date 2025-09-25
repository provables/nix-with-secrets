# This is an example file for testing the `example` app in the flake.
# DO NOT USE this key elsewhere. The private key is included here as a test.
let
  aUser = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhX1k4j4KK+oRQHd0Roz7xCVa9KjDldjD8kiI98Sm9d";
  users = [ aUser ];
in
{
  "secret1.age".publicKeys = users;  # a secret accessible for all `users`
  "secret2.age".publicKeys = [ aUser ];  # a secret accessible only to a specific user
}
