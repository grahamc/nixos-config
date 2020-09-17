{ lib, pkgs, config, ... }:
let
  address = (if config.services.vault.tlsKeyFile == null
    then "http://"
    else "https://") + config.services.vault.address;

  plugin_args = (if config.services.vault.tlsKeyFile == null
    then ""
    else "-ca-cert=/run/vault/certificate.pem");


  # note: would like to buildEnv but vault rejects symlinks :/
  plugins = {
    pki = {
      type = "secret";

      # vault kv put packet/config api_token=-
      # vault kv put packet/role/nixos-foundation type=project ttl=30 max_ttl=3600 project_id=86d5d066-b891-4608-af55-a481aa2c0094 read_only=false
    };

    packet = {
      type = "secret";
      package = pkgs.vault-plugin-secrets-packet;
      command = "vault-plugin-secrets-packet";

      # vault kv put packet/config api_token=-
      # vault kv put packet/role/nixos-foundation type=project ttl=30 max_ttl=3600 project_id=86d5d066-b891-4608-af55-a481aa2c0094 read_only=false
    };
    oauthapp = {
      # wl-paste | vault write oauth2/github/config -provider=github client_id=theclientid client_secret=- provider=github

      # scopes: https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/
      # vault write oauth2/bitbucket/config/auth_code_url state=foo scopes=bar,baz

      # vault write oauth2/github/config/auth_code_url state=$(uuidgen) scopes=repo,gist
      # now it is broken ... https://github.com/puppetlabs/vault-plugin-secrets-oauthapp/issues/4
      type = "secret";
      package = pkgs.vault-plugin-secrets-oauthapp;
      command = "vault-plugin-secrets-oauthapp";
    };
  };
  mounts = {
    "pki_ca/" = {
      plugin = "pki";
    };
    "pki_intermediate/" = {
      plugin = "pki";
    };
    "packet/" = {
      plugin = "packet";
    };
    "oauth2/github/" = {
      plugin = "oauthapp";
    };
  };
  pluginsBin = pkgs.runCommand "vault-env" {}
  ''
    mkdir -p $out/bin

    ${builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (name: info:
    if info ? package then
    ''
      (
        echo "#!/bin/sh"
        echo 'exec ${info.package}/bin/${info.command} "$@"'
      ) > $out/bin/${info.command}
      chmod +x $out/bin/${info.command}
    '' else ""
    ) plugins)}
  '';

  #plugins = pkgs.buildEnv {
  #  name = "vault-plugins";
  #  paths = with pkgs; [ vault-plugin-secrets-packet ];
  #};


  writeCheckedBash = pkgs.writers.makeScriptWriter {
    interpreter = "${pkgs.bash}/bin/bash";
    check = "${pkgs.shellcheck}/bin/shellcheck";
  };

  vault-setup = writeCheckedBash "/bin/vault-setup" ''
    PATH="${pkgs.glibc}/bin:${pkgs.procps}/bin:${pkgs.vault}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin:/run/wrappers/bin"

    scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
    function finish {
      rm -rf "$scratch"
    }
    trap finish EXIT
    chmod 0700 "$scratch"

    export VAULT_ADDR=${address}
    export VAULT_CACERT=/run/vault/certificate.pem

    if vault status --format json | jq -e '.sealed'; then
      ${pkgs.pass}/bin/pass vault-petunia | ${pkgs.expect}/bin/expect
    fi

    vault secrets disable pki_ca || true
    vault secrets disable pki_intermediate || true

    ${builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (name: value:
      if value ? package then
      ''
        expected_sha_256="$(sha256sum ${pluginsBin}/bin/${value.command} | cut -d " " -f1)"

        echo "Re-registering ${name}"
        vault plugin register -command "${value.command}" -args="${plugin_args}" -sha256 "$expected_sha_256" ${value.type} ${name}
        vault write sys/plugins/reload/backend plugin=${name}
      '' else ""
    ) plugins)}

    ${builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (path: info:
      ''
        if ! vault secrets list -format json | jq -e '."${path}"?'; then
          vault secrets enable -path=${path} ${info.plugin}
        fi
      ''
    ) mounts)}

    # Replace our selfsigned cert with a weird key, with a vault-made
    # key.
    # 720h: the laptop can only run for 30 days without a reboot.
    vault secrets tune -max-lease-ttl=720h pki_ca
    sleep 1

    echo "Generating root certificate"
    vault delete pki_ca/root/generate/internal || true
    vault write -field=certificate pki_ca/root/generate/internal \
      common_name="localhost" \
      ttl=721h > "$scratch/root-certificate.pem"

    vault write pki_ca/config/urls \
        issuing_certificates="${address}/v1/pki/ca" \
        crl_distribution_points="${address}/v1/pki/crl"
    sleep 1

    echo "Generating intermediate certificate"
    vault secrets tune -max-lease-ttl=720h pki_intermediate
    vault write -format=json pki_intermediate/intermediate/generate/internal \
        common_name="localhost Intermediate Authority" \
        | jq -r '.data.csr' > "$scratch/pki_intermediate.csr"

    vault write -format=json pki_ca/root/sign-intermediate csr=@"$scratch/pki_intermediate.csr" \
        format=pem_bundle ttl="3h" \
        | jq -r '.data.certificate' > "$scratch/intermediate.cert.pem"
    vault write pki_intermediate/intermediate/set-signed certificate=@"$scratch/intermediate.cert.pem"
    sleep 1

    echo "Generating Vault's certificate"
    vault write pki_intermediate/roles/localhost \
        allowed_domains="localhost" \
        allow_subdomains=false \
        max_ttl="3h"

    vault write -format json pki_intermediate/issue/localhost \
      common_name="localhost" ttl="2h" > "$scratch/short.pem"

    jq -r '.data.certificate' < "$scratch/short.pem" > "$scratch/certificate.server.pem"
    jq -r '.data.ca_chain[]' < "$scratch/short.pem" >> "$scratch/certificate.server.pem"
    jq -r '.data.private_key' < "$scratch/short.pem" > "$scratch/vault.key"

    sudo mv "$scratch/root-certificate.pem" /run/vault/certificate.pem
    sudo mv "$scratch/vault.key" /run/vault/vault.key
    sudo mv "$scratch/certificate.server.pem" /run/vault/certificate.server.pem

    sudo pkill --signal HUP vault
  '';


in {
  services.vault = {
    enable = true;
    address = "localhost:8200";
    storageBackend = "file";
    storagePath = "/rpool/persist/vault/";
    extraConfig = ''
      api_addr = "${address}"
      plugin_directory = "${pluginsBin}/bin"
      log_level = "trace"
    '';
    tlsCertFile = "/run/vault/certificate.server.pem";
    tlsKeyFile = "/run/vault/vault.key";
  };

  environment.systemPackages = [ vault-setup ];
  systemd.services.vault-tls-bootstrap = {
    wantedBy = [ "vault.service" ];
    path = with pkgs; [ openssl ];
    unitConfig.Before = [ "vault.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''

      rm -rf /run/vault
      mkdir /run/vault

      touch /run/vault/vault.key
      chmod 0600 /run/vault/vault.key

      touch /run/vault/certificate.pem
      chmod 0644 /run/vault/certificate.pem

      openssl req -x509 -subj /CN=localhost -nodes -newkey rsa:4096 -days 1 \
        -keyout /run/vault/vault.key \
        -out /run/vault/certificate.pem

      cp  /run/vault/certificate.pem  /run/vault/certificate.server.pem

      chown ${config.systemd.services.vault.serviceConfig.User}:${config.systemd.services.vault.serviceConfig.Group} /run/vault/{vault.key,certificate.pem}

    '';
  };
}
