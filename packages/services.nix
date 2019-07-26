{
  imports = [
    ./recognize-thunderbolt/service.nix
    ./aenea/service.nix
    ./autorandr-configs/service.nix
    ./nitrokey/service.nix
    ./symlinks/service.nix
    ./is-nix-channel-up-to-date/service.nix
    ./did-graham-commit-his-repos/service.nix
    ./systemd-lock-handler/service.nix
    ./systemd-boot/systemd-boot.nix
    ./ttf-console-font/service.nix
  ];
}
