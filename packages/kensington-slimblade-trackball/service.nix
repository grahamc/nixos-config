{
  # Kensington SlimBlade trackball sometimes auto-power-off's.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idProduct}=="2041", ATTRS{idVendor}=="047d", TEST=="power/control", ATTR{power/control}="on"
  '';
}
