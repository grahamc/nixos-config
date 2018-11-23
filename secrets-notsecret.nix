let
  locations = {
    home = {
      latitude = "10.0";
      longitude = "10.0";
      timezone = "America/New_York";
      remote_timezones = [ "Europe/Paris" ];
    };
  };
in rec {
  location = locations.home;
  inherit (location) latitude longitude timezone;
  hashedPassword = "abc123";

  buildMachines = [
  ];
}
