{
  imports = [
    ./nitrokey/service.nix
    ./symlinks/service.nix
    ./is-nix-channel-up-to-date/service.nix
    ./did-graham-commit-his-repos/service.nix
    ./systemd-lock-handler/service.nix
  ];
}
