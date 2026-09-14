{ lib }:
rec {
  user = {
    name = "";
    email = "";
    workEmail = "";
    hashedPassword = "";
  };

  rbw-settings = {
    base_url = "";
    email = user.email;
  };

  sshHosts.rhea = {
    Hostname = "rhea";
    Port = 22;
  };
  wg-quick.interfaces = { };
  dockerRegistryMirror = "";
  customCACertificates = [ ];
  cargoRegistries = { };
  extraHosts = { };
  wifiHome = {
    ssid = "";
    psk = "";
  };
}
