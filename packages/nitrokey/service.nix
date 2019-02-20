{ pkgs, ... }:
{
  services.udev.extraRules = builtins.readFile (pkgs.fetchurl {
    url = "https://www.nitrokey.com/sites/default/files/40-nitrokey.rules";
    sha256 = "1208956k294hfc0jfb6p1ypascdylsyizbc7051b5ixj0w3d3shg";
  });

  services.pcscd = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    pcsctools
  ];
}
