{ lib, pkgs, config, ... }:
let
  address = (if config.services.vault.tlsKeyFile == null
    then "http://"
    else "https://") + config.services.vault.address;

  # note: would like to buildEnv but vault rejects symlinks :/
  plugins = {
    packet = {
      type = "secret";
      package = pkgs.vault-plugin-secrets-packet;
      command = "vault-plugin-secrets-packet";
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
    ''
      (
        echo "#!/bin/sh"
        echo 'exec ${info.package}/bin/${info.command} "$@"'
      ) > $out/bin/${info.command}
      chmod +x $out/bin/${info.command}
    ''
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
    PATH="${pkgs.glibc}/bin:${pkgs.vault}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin:\$PATH"


    export VAULT_ADDR=${address}

    if vault status --format json | jq -e '.sealed'; then
      ${pkgs.pass}/bin/pass vault-petunia | ${pkgs.expect}/bin/expect
    fi

    ${builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (name: value:
      ''
        expected_sha_256="$(sha256sum ${pluginsBin}/bin/${value.command} | cut -d " " -f1)"

        if ! vault plugin info ${value.type} ${name}; then
          echo "Registering ${name}"
          vault plugin register -command "${value.command}" -sha256 "$expected_sha_256" ${value.type} ${name}
        elif [ "$(vault plugin info -field sha256 ${value.type} ${name})" != "$expected_sha_256" ]; then
          echo "Re-registering ${name}"
          vault plugin register -command "${value.command}" -sha256 "$expected_sha_256" ${value.type} ${name}
          vault write sys/plugins/reload/backend plugin=${name}
        fi
      ''
    ) plugins)}

    ${builtins.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (path: info:
      ''
        if ! vault secrets list -format json | jq -e '."${path}"?'; then
          vault secrets enable -path=${path} ${info.plugin}
        fi
      ''
    ) mounts)}
  '';
in {
  services.vault = {
    enable = true;
    storageBackend = "file";
    storagePath = "/rpool/persist/vault/";
    extraConfig = ''
      api_addr = "${address}"
      plugin_directory = "${pluginsBin}/bin"
      log_level = "trace"
    '';
  };

  environment.systemPackages = [ vault-setup ];
}
