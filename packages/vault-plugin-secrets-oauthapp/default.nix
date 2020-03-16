{ buildGoModule, fetchFromGitHub }:
buildGoModule {
  name = "vault-plugin-secrets-oauthapp";
  version = "1.1.1";
  src = fetchFromGitHub {
    owner = "puppetlabs";
    repo = "vault-plugin-secrets-oauthapp";
    rev = "v1.1.1";
    sha256 = "1i0mp6br6n4pyxkfd4w3pccfdawfj7zwia5xn52dabqdjb54m39h";
  };
  modSha256 = "1ymbxnvxp0xa611mz010an3mjqh4asd6b1wc401jmq5rrmf9lnjx";
  subPackages = [ "cmd/vault-plugin-secrets-oauthapp" ];
}
