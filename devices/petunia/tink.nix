{
  networking.interfaces.tink = {
    virtual = true;
    ipv4.addresses = [
      {
        address = "192.168.172.1";
        prefixLength = 29;
      }
      {
        address = "192.168.172.2";
        prefixLength = 29;
      }
    ];
  };
}
