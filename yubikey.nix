{ config, stdenv, ... }:
{
  services.udev.extraRules = ''
      
      # this udev file should be used with udev 188 and newer
	    ACTION!="add|change", GOTO="u2f_end"

      # Yubico YubiKey
            KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", MODE="0660", GROUP="plugdev", TAG+="uaccess"

      LABEL="u2f_end"
  '';

}