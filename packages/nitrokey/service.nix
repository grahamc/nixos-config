{ pkgs, ... }:
{
  services.udev.extraRules = builtins.readFile (pkgs.fetchurl {
    url = "https://www.nitrokey.com/sites/default/files/40-nitrokey.rules";
    sha256 = "127nghkfd4dl5mkf5xl1mij2ylxhkgg08nlh912xwrrjyjv4y9sa";
  });

  services.pcscd = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    pcsctools
  ];
}
